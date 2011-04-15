# -*- coding: utf-8 -*-
require "rubygems"
require "hpricot"
require 'open-uri'
require "iconv"
require 'yaml'
require "drymon"
require 'uri'


module Drymon
  class Lime
    def make file=nil
      opts = OptionParser.new("Usage: #{File::basename($0)} URI")
      opts.on("-v", "--version", "show version") do
        puts "%s %s" %[File.basename($0), Drymon::VERSION]
        puts "ruby %s" % RUBY_VERSION
        exit
      end
      opts.version = Drymon::VERSION
      opts.parse!(ARGV)
      if file == nil
        file = ARGV[0]
      end
      unless file
        puts "Usage: #{File::basename($0)} Dir"
        puts "Usage: #{File::basename($0)} Filename"
        exit
      end

      if File::ftype(file) == "directory"
        Dir::glob(file+"/*.yml").each {|f|
          gen(f)
        }
      else
        gen(file)
      end

    end

    def gen(filename)
      data = YAML.load(open(filename).read)
      #domain用のフォルダー作成ルーチンを通すこと
      basedir = "output/"+URI.parse(data["domain"]).host
      unless File.exists?(basedir)
        Dir::mkdir(basedir)
      end

      unless File.exists?(basedir+"/lime")
        Dir::mkdir(basedir+"/lime")
      end

      actions = data["actions"]
      #暫定対応
      action = actions[0]
      action["module"] ||= ""
      action["action"] ||= ""
      post_data = "->isParameter('module','"+action["module"]+"') \n";
      post_data = post_data + "  ->isParameter('action','"+action["action"]+"') \n";
      
      submit_data = String("")
      
      action["post_params"].each do |key,value|
        post_data = post_data + sprintf("  ->isParameter('"+key+"','"+value+"')\n")
      end
      
      response_data = String("")
      data["response"].each do |key,value|
        response_data = response_data + sprintf("  ->checkElement('"+key+"','"+value+"')\n")
      end
      
      output =  Time.now.strftime("output/"+URI.parse(data["domain"]).host+"/lime/"+File::basename(filename)+".php")
      open(output, "w") do |f|
        f.write <<"EOS"
$test->info('test for #{action["module"]} #{action["action"]}')
  ->click("#{submit_data}")
  ->with("request")->begin()
  #{post_data}->end()
  ->with('response')->begin()
  #{response_data}->end()
EOS
      puts 'output file: '+output

      end
    end
  end
end



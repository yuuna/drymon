# -*- coding: utf-8 -*-
require "rubygems"
require "hpricot"
require 'open-uri'
require "iconv"
require 'yaml'
require "drymon"
require "optparse"
require 'uri'

module Drymon
  class Url
    attr_accessor  :module, :action
    def form(url=nil)
      opts = OptionParser.new("Usage: #{File::basename($0)} URI")
      opts.on("-v", "--version", "show version") do
        puts "%s %s" %[File.basename($0), Drymon::VERSION]
        puts "ruby %s" % RUBY_VERSION
        exit
      end
      opts.version = Drymon::VERSION
      opts.parse!(ARGV)
      if url == nil
        url = ARGV[0]
      end
      unless url
        puts "Usage: #{File::basename($0)} URI"
        exit
      end

      f = open(url)
      f.rewind
      if f.charset == "shift_jis"
        charset = "sjis"
      else
      charset = f.charset
      end
      
      doc = Hpricot(Iconv.conv('utf-8',charset,f.readlines.join("\n")))
      title =  (doc/'title').inner_html
      
      forms = Hash.new()
      forms["domain"] = url
      forms["actions"] = Array.new()
      doc.search("form").each do |elem|

        action = Hash.new
        action["path"] = elem[:action]
        action["method"] = elem[:method] || "post"
        action["module"] = @module || nil
        action["action"] = @action || nil
        action["post_params"] = Hash.new

        elem.search("input").each do |elem_i|
          action["post_params"][elem_i[:name]] = elem_i[:value]
        end
        forms["actions"] << action
      end
      
      forms["response"] = {"tag" => "value"}
      

      #この後ファイルに書き出して終わり
      Drymon::save_yaml(Drymon::output_filename(url),forms)
   end
  end
end


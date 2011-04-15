# -*- coding: utf-8 -*-
require "rubygems"
require "hpricot"
require 'open-uri'
require "iconv"
require 'yaml'
require "drymon"
require "active_support/core_ext"


module Drymon
  class Selenium

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

      unless File.exists?(basedir+"/selenium")
        Dir::mkdir(basedir+"/selenium")
      end
      action = data["actions"][0]
    
      output =  Time.now.strftime("output/"+URI.parse(data["domain"]).host+"/selenium/"+File::basename(filename)+".php")

      open(output, "w") do |f|
        f.write <<"EOS"
<?php
require_once 'PHPUnit/Extensions/SeleniumTestCase.php';
class WebTest extends PHPUnit_Extensions_SeleniumTestCase
  {
    protected function setUp()
    {
      $this->setBrowser('*firefox');
      $this->setBrowserUrl('#{data["domain"]}');
    }
EOS

    assertValue = String("");
    data["response"].each do |key,value|
      assertValue += "$this->assertTrue((bool)preg_match($this->isTextPresent(\"#{$value}\")));\n";
    end


    data["actions"].each do |row|
      testclassname = row["module"].to_s.classify + row["action"].to_s.classify
      submit_data = String("")
      post_data = String("")
      row["post_params"].each do |key2,value|
        post_data = post_data + "\t\t\t$this->type(\"#{key2}\",\"#{value}\"); \n"
      end

      

      f.write <<"EOS"
      function test#{testclassname}()
      {
      $this->open("#{row["path"]}");
      #{post_data}
      $this->click("submit");
      $this->waitForPageToLoad("30000");
      #{assertValue}
      }
}
?>
EOS
    end
    puts 'output file: '+output
  end

    end
  end
end

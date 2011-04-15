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
  class Config
   def self.copy
     unless File.exists?("./config")
       Dir::mkdir("./config")
     end
     FileUtils.cp(File.expand_path("../../../config", __FILE__)+'/openpne.yml','./config/') 
     FileUtils.cp(File.expand_path("../../../config", __FILE__)+'/drymon.yml','./config/') 
     unless File.exists?("./yml")
       Dir::mkdir("./yml")
     end
     unless File.exists?("./output")
       Dir::mkdir("./output")
     end

   end
  end
end


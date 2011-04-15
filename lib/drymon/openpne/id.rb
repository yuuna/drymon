# -*- coding: utf-8 -*-
require "rubygems"
require "hpricot"
require 'open-uri'
require "iconv"
require 'yaml'

module Drymon
  module Openpne
    class Id
      attr_accessor :file,:list
      def initialize
        @list = Array.new
      end

      def file(filename = nil)
        opts = OptionParser.new("Usage: #{File::basename($0)} URI")
        opts.on("-v", "--version", "show version") do
          puts "%s %s" %[File.basename($0), Drymon::VERSION]
          puts "ruby %s" % RUBY_VERSION
          exit
        end
        opts.version = Drymon::VERSION
        opts.parse!(ARGV)
        if filename == nil
        filename = ARGV[0]
        end
        unless filename
          puts "Usage: #{File::basename($0)} action-list"
          exit
        end

        File.open(filename) {|file|
          while l = file.gets
            @list << l.chomp!.split("\t")[1]
          end
        }
        @list.uniq!
      end

      def write(args)
        printf(@file,"%s: 1\n",args)
      end
      def output
        if @list.size > 0
          @file = open("config/openpne_id.yml","w")
          @list.each{|value| write(value)}
          @file.close
        end
      end

    end
  end
end



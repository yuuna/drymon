# -*- coding: utf-8 -*-
require "rubygems"
require "hpricot"
require 'open-uri'
require "iconv"
require 'yaml'
require "drymon"
require "drymon/url"
require "mechanize"
require "uri"

module Drymon
  class Pne
    attr_accessor :config,:openpne,:forms,:module,:action,:ids
    
    def initialize
      @config = Drymon::load_config
      @openpne =Drymon::load_config("openpne.yml")
      @forms = Hash.new
      @forms["domain"] = @openpne['domain']      
      @forms["actions"] = Array.new
      if File.exist? "config/openpne_id.yml"
        @id = Drymon::load_config("openpne_id.yml")
      else
        puts "No Fixtures file list."
      end
    end
    def get(path)
      begin
        agent = Mechanize.new
        agent.user_agent = @config['user_agent']
        page = agent.get(@openpne['domain']+@openpne['path'])
        form = page.forms.first
        form.field_with(:name => 'authMailAddress[mail_address]').value = @openpne['username']
        form.field_with(:name => 'authMailAddress[password]').value = @openpne['password']
        result = agent.submit(form)

        


        if path =~ /^\//
          path = path.slice(1,path.length-1)
        end
        if path =~ /:id/  && @id.has_key?(@module)
          if @id[@module].class.to_s == "String" || @id[@module].class.to_s == "Fixnum"
            path.sub!(/:id/,@id[@module].to_s)
          else @id[@module].class.to_s == "Hash"
            if @id[@module].has_key?(path)
              path.sub!(/:id/,@id[@module][path].to_s)
            else
              path.sub!(/:id/,@id[@module]["id"].to_s)
            end
          end
        end



        action = {"path" => @openpne["path"]+path}
        @forms["actions"] << action
      
        agent.get(path).forms.each do |form|
          unless form.action =~ /language/           
            action=Hash.new
            action["path"] = form.action
            action["method"] = form.method
            action["module"] = @module ||nil 
            action["action"] = @action ||nil
            action["post_params"] = Hash[*form.build_query.flatten]
            if action["path"] != "" || action["path"] != nil
              @forms["actions"] << action
              @forms["response"] = {"tag" => "value"}
              Drymon::save_yaml(Drymon::output_filename(@openpne["domain"]+ @openpne['path']+path),@forms)

              @forms["actions"].pop
              @forms["response"] = {}
            end
          end

          @forms["actions"] =Array.new
          @forms["response"] = {}
        end
      rescue 
        @forms["actions"] =Array.new
        @forms["response"] = {}
        p "error is occurred: "+path
      end

     end

    def load filename=nil
      
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
          
        row =l.split("\t")
          
          if (row.length == 2 || row.length == 5 )
            @module = row[1]
            @action = row[0]
            if row.length == 2
              get(row[0])
            elsif row.length == 5
              get(row[3])
            end
          end
        end
      }
    end
  end
end


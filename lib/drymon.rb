require 'drymon/url'
require 'drymon/pne'
require 'drymon/config'
require 'drymon/lime'
require 'drymon/selenium'
require 'drymon/openpne/id'


module Drymon
  VERSION = '0.0.3'
  def output_filename(url)

    basedir = "yml/"+URI.parse(url).host
      unless File.exists?(basedir)
        Dir::mkdir(basedir)
      end
    filename = URI.parse(url).path.gsub(/\//,"_")
      if filename == "_" || filename == nil
        filename = "index"
      end
    output = sprintf("%s/%s-%s.yml",basedir,Time.now.strftime("%Y%m%d-%H%M%S"),filename)
    sleep 1
    return output

  end

    def save_yaml(file, hash)
      require 'syck/encoding'
      hakaiheader = {"loop" => 10,"max_request" =>  5,"max_scenario" => 5,"log_level" =>  2, "ranking" => 20,"timeout"=> 5,"show_report" =>  true,"save_report" =>  false,"encoding" => "UTF-8"}

      open(file, "w") do |f|
        f.write(Syck::unescape(YAML::dump(hakaiheader)).gsub("---",""))
        f.write(Syck::unescape(YAML::dump(hash)).gsub("---",""))
        f.flush
      end
#      puts 'output file: '+file
    end

    def load_config(config = 'drymon.yml')
      YAML.load_file("config/"+config) 
    end


  module_function :save_yaml , :load_config , :output_filename
end

require 'rubygems'
require 'pp'
require 'json'
require 'typhoeus'

namespace :wikimapia do
  desc 'download json'
  task :geojson do
    KEY = "AB9CA4F4-2903429B-120A802A-B63C075F-3F00062A-CBBE91B9-BBB6AF34-A32CFE63"
    TOWN_NAMES_FILE = "db/data/karachi_union_councils.yml"
    API_URL = "http://api.wikimapia.org/?function=object&key=#{KEY}&id=[[id]]&format=json"
    RAW_JSON = "db/data/raw_wikimapia.json"

    data = YAML.load_file(TOWN_NAMES_FILE)
    data["towns"].each do |name, attrs|
      # pp name
      # pp attrs['wikimapia_id']
      url = API_URL.gsub('[[id]]', attrs['wikimapia_id'].to_s)
      # pp url
      response = Typhoeus::Request.get(url)
      puts response.body
      # File.open(RAW_JSON, 'w+'){ |f| f.puts(response.body) } 

      # str = File.open(RAW_JSON, 'r').read
      # pp str
      # hash = JSON.parse(File.open(RAW_JSON, 'r').read)
      # pp hash
      # pp "\n#---------------------------------------\n"
    end
  end

  desc 'parse json'
  task :parse_json, :file do |t, args|
    jsonfile = args[:file]
    str = File.open(jsonfile, 'r').read
    hash = JSON.parse(str)
    pp hash
  end
end

module WikimapiaHelper
  def self.json2geojson
    # ...
  end
end

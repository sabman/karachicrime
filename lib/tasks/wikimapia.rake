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
    geojson_hash              = WikimapiaHelper::geojson_hash
    feature                   = WikimapiaHelper::geojson_hash["features"][0]
    geojson_hash["features"]  = []
    features                  = []
    hash.each do |rec|
      feature["geometry"]["coordinates"] = [rec["polygon"].collect{|xy| [xy["x"], xy["y"]] }]
      feature["properties"] = {
        "wikimapia_id"  => rec["id"],
        "description"   => rec["description"],
        "wikipedia_url" => rec["wikipedia"]
      }
      features << feature
    end
    geojson_hash["features"] = features
    puts geojson_hash.to_json
  end
end

module WikimapiaHelper
  def self.json2geojson
    # ...
  end

  def self.geojson_hash
    JSON.parse self.geojson_template
  end

  def self.geojson_template
    '{ "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
               [100.0, 1.0], [100.0, 0.0] ]
            ]
          },
          "properties": {
            "prop0": "value0",
            "prop1": {"this": "that"}
          }
        }
      ]
    }'
  end
end

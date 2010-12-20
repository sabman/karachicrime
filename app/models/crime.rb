class Crime
  include MongoMapper::Document
  plugin GeoSpatial
  
  key :case_id, Integer
  key :reported_at, Time, :required => true
  key :district, Integer
  key :precinct, String
  key :address, String
  key :union_council, String
  key :loc, Hash, :default => {'lat' => 0, 'lon' => 0}
  key :code, String
  timestamps!
  
  belongs_to :offense
  belongs_to :neighborhood
  
  add_concerns :reporting
  
  scope :between, lambda {|from, to| where(:reported_at.gte => from, :reported_at.lt => to) }
    
  scope :in_the_past, lambda {|time|   
    where(:reported_at.gte => Time.zone.now.change(:hour => 0) - time, 
          :reported_at.lt => Time.zone.now).sort(:reported_at.desc)}
  
  def as_geojson(options = {})
    props = attributes
    props.delete(:loc)
    geojson = {
      :id => id.to_s,
      :type => 'Feature',
      :properties => props,
      :geometry => {
        :type => 'Point', 
        :coordinates => [loc['lon'], loc['lat']]
      }
    }
    logger.info(geojson.inspect)
    geojson
  end
  
  def at_dark?
    hour = reported_at.hour
    hour >= 18 || hour < 6
  end
  
  def at_daylight?
    hour = reported_at.hour
    hour >= 6 && hour < 18
  end
end

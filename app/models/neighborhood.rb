class Neighborhood
  include MongoMapper::Document 

  key :name
  key :permalink
  key :karachi, Boolean, :default => true
  key :geo, Hash
  key :loc, Hash, :default => {'lat' => 0, 'lon' => 0}
  key :properties, Hash
  key :wikipedia_pageid

  timestamps!

  many :crimes
  many :demographics # For future historical demographics

  add_concerns :reporting

  scope :karachi_only, where(:karachi => true)

  def to_param
    permalink
  end

  def as_geojson(options = {})
    {
      :id => id,
      :geometry => (geo ||
        {:geometry => { :type => 'Point', :coordinates => [loc['lon'], loca['lat']] }}
      ),
      :properties => properties.merge(:name => name, :permalink => permalink)
    }
  end
end
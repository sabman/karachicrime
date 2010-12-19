class Neighborhood
  include MongoMapper::Document 

  key :name
  key :permalink
  key :portland, Boolean, :default => false
  key :karachi, Boolean, :default => true
  key :geo, Hash
  key :loc, Hash, :default => {'lat' => 0, 'lon' => 0}
  key :properties, Hash
  key :wikipedia_pageid

  timestamps!

  many :crimes
  many :demographics # For future historical demographics

  add_concerns :reporting

  scope :portland_only, where(:portland => true)
  scope :portland_only, where(:karachi => true)

  def to_param
    permalink
  end

  def as_geojson(options = {})
    {
      :id => id,
      :geometry => (geo ||
        {:geometry => { :type => 'Point', :coordinates => [lon, lat] }}
      ),
      :properties => properties.merge(:name => name, :permalink => permalink)
    }
  end
end
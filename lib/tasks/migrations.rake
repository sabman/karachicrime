# This is a temporary solution to migrations.  Look into mongrations or another 
# solution.

require 'name_map'
require 'csv'
require 'pp'
require 'geonames'

namespace :migrations do
  desc 'Load the names of Karachi neighbourhoods'
  task :karachi_neighborhood_names => :environment do
    require "#{Rails.root}/vendor/plugins/wikipedia-client/lib/wikipedia"

    nhoods = CSV.read('db/data/karachi_towns.txt', :headers => true)
    nhoods.each do |row|
      puts "------------------------------------------------------------"
      attrs = {:name => row['name'].titlecase, :permalink => row['name'].parameterize}
      pp attrs
      n = Neighborhood.first_or_new(:name => row['name'].titlecase)
      n.update_attributes(attrs)
      puts "saving #{n.name}..." ; n.save!
      puts "------------------------------------------------------------"
    end
  end

  desc 'Convert neighborhood names to normalized names and add geo data'
  task :one_normalize_neighborhood_names => :environment do
    nhoods = JSON.parse(File.read(File.join(Rails.root, 'db', 'data', 'karachi_towns.json')))
    puts nhoods['features']
    Neighborhood.all.each do |n|
      puts "\n>>>>>>>>>>> #{n.name}"
      name = n.name
      cur_name = n.name.downcase.strip

      nhood = nhoods['features'].detect { |f| f['properties']['title'].downcase.strip == cur_name }
      puts "\n  >>>>>>>>>>> #{nhood.class}"

      if nhood.nil? 
        puts "\n    >>>>>>>>>>> #{nhood['properties']['title'].downcase} not found!"
      end
      
      unless nhood.nil?        
        n.name = name.titlecase
        n.geo = nhood['geometry']
        n.properties = nhood['properties']
        n.save
        puts "\n    >>>>>>>>>>> #{nhood['properties']['title'].downcase} saved!"
      end
    end
  end
  
  # Migration for noob mistake
  desc 'Correct improper neighborhood name imports'
  task :two_unify_same_neighborhoods => :environment do
    PDX_NHOODS_NAME_MAP.each do |k, v|
      cn = Neighborhood.first(:name => v.titlecase)
      cn.permalink = v.parameterize
      cn.save
      
      # The crime importer wasn't swapped over to use the name map, so this needs
      # to be corrected by finding all neighborhoods in the name map and assigning
      # their crimes to the correct neighborhood
      nh = Neighborhood.first(:permalink => k.parameterize)
      unless nh.nil?
        correct_nh = Neighborhood.first(:permalink => v.parameterize)
        if correct_nh.nil?
          puts "COULDN'T FIND #{v}"
        else
          nh.crimes.each do |c|
            c.neighborhood = correct_nh
            if c.save
              nh.destroy
            end
          end
        end
      end
    end
    
    
    # Now we need to find all neighborhoods that aren't in the name map, but 
    # have the exact same name (e.g. WOODSTOCK and Woodstock)

    Neighborhood.all.each do |nhood|
      count = Neighborhood.count(:name => /^#{nhood.name}$/i)
      if count >= 2 && !nhood.name.blank?
        correct = Neighborhood.first(:name => nhood.name.titlecase)
        duplicate = Neighborhood.first(:name => nhood.name.upcase)
        
        unless duplicate.nil?
          puts "Moving #{duplicate.crimes.count} from #{duplicate.name} to #{correct.name}"
          duplicate.crimes.each do |crime|
            crime.neighborhood = correct
            if crime.save
              duplicate.destroy
            end
          end
        else
          # For some reason we didn't find an upcased duplicate.  In that case, just pick one
          # and assign all crimes to it, deleting the dupes
          puts "UNABLE TO FIND PROPER DUP FOR #{correct.name}. Consolidating to one and deleting dupes."
          Neighborhood.all(:name => nhood.name.titlecase).each do |nh|
            nh.crimes.each do |c|
              c.neighborhood = correct
              c.save
              nh.destroy if nh != correct
            end
          end
        end
      end
    end
  end
  
  desc 'Import Neighborhood Demographic Data'
  task :three_import_neighborhood_demographics => :environment do
    data = File.join(Rails.root, 'db', 'data', 'neighborhood-demographics.csv')
    nhoods = CSV.read(data, :headers => true)
    Neighborhood.all.each do |n|
      found = nhoods.detect do |nh|
        n.name.parameterize == nh['NEIGHBORHOOD'].parameterize ||
        (PDX_DEMOGRAPHICS_NAME_MAP[n.permalink] && PDX_DEMOGRAPHICS_NAME_MAP[n.permalink].downcase == nh['NEIGHBORHOOD'].downcase)
      end
      
      if found
        props = found.to_hash
        props.delete('NEIGHBORHOOD')
        props.each do |k, v|
          props[k] = v.gsub(',', '').to_i
        end

        demographic = n.demographics.detect {|d| d.year == 2000 }
        if demographic.nil?
          demographic = Demographic.new(:year => 2000)
          n.demographics << demographic
        end
        demographic.properties = props
        if n.save
          puts "Imported demographics for #{n.name}"
        end
      end
    end
  end
  
  desc 'Flag non-karachi neighborhoods'
  task :four_flag_non_karachi_neighborhoods => :environment do
    permalinks = NON_PDX_NHOODS.collect {|n| n.parameterize }
    Neighborhood.all.each do |nh|
      if permalinks.include?(nh.permalink)
        nh.karachi = false
      else
        nh.karachi = true
      end
      nh.save
    end
  end
end
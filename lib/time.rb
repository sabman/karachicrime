class Time 
  def self.random(years_back=1)
    Time.now - rand(60 * 60 * 24 * 364.75 * years_back)
  end 
end 

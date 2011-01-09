require 'pp'
require 'uri'

sender    = 1234567890
content   = "Crime report of theft in Nazimabad"
inNumber  = 4412234567890
email     =  "shoaib@nomad-labs.com"
credits   = 100
lat       = 24.7796
long      = 67.1885
rad       = 10
lbscredits= 25

data = "sender=#{sender}&content=#{content}&inNumber=#{inNumber}&email=#{email}&credits=#{credits}&lat=#{lat}&long=#{long}&rad=#{rad}&lbscredits=#{lbscredits}"

resource_url = "localhost:3000/sms/callback"

data = URI.escape(data)
pp data

system "curl --data \'#{data}\' #{resource_url}"
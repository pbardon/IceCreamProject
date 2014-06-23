require 'addressable/uri'
require 'rest-client'
require 'nokogiri'
require 'json'

File.open('.api_key', 'r') do |f|
  $api_key = f.readlines.first
end

# puts "Please enter your street address:"
# st = gets.chomp
# puts "Enter city:"
# cty =  gets.chomp
# puts "Enter state or country:"
# region = gets.chomp

# $address = st + ', ' + cty + ', ' + region

$address = "1061 Market St, San Francisco, CA"

geolocationaddress = Addressable::URI.new(
                                          :scheme => "http",
                                          :host => "maps.googleapis.com",
                                          :path => "maps/api/geocode/json",
                                          :query_values => {address: $address}
                                        ).to_s


output = JSON.parse(RestClient.get(geolocationaddress))

results = output["results"].first
location = results['geometry']['location']
lat = location["lat"]
long = location["lng"]

coordinates = "#{lat},#{long}"

puts coordinates


search_address = Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/place/nearbysearch/json",
  :query_values => {key: $api_key, location: coordinates, keyword: "Ice Cream", types: 'food', radius: '1000', sensor: false}
).to_s
p search_address

search_output = JSON.parse(RestClient.get(search_address))



nearby_shops = search_output["results"].map{|result| result["name"]}

puts nearby_shops

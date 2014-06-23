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
    :query_values => { 
                       key: $api_key,
                       location: coordinates,
                       keyword: "Ice Cream",
                       types: 'food',
                       radius: '1000',
                       sensor: false
                     }
).to_s


search_output = JSON.parse(RestClient.get(search_address))


shopcoords = []
shop_names = []
nearby_shops = search_output["results"]

nearby_shops.each do |shop|
  shop_location = shop["geometry"]["location"]
  shop_lat = shop_location["lat"]
  shop_long = shop_location["lng"]
  shop_names << shop["name"]
  shopcoords << "#{shop_lat},#{shop_long}"
end




shopcoords.each_with_index do |coord, index|

  directions_address = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json",
      :query_values => {
                        origin: coordinates,
                        destination: coord
                      }
  ).to_s


  dir_output = JSON.parse(RestClient.get(directions_address))

  route = dir_output['routes'].first
  steps = route['legs'].first['steps']
  
  puts shop_names[index]
  puts "______________________"
  puts
  instructions = steps.map do |step|
    parsed_html = Nokogiri::HTML(step['html_instructions']).text
  end
  instructions.each {|step| puts step}
  puts
end



  

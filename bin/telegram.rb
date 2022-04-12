#!/usr/bin/env ruby

require 'uri'
require 'net/http'

puts "Runs telegram demon"
uri = URI('https://kyrgyzpassport.herokuapp.com/telegram')
res = Net::HTTP.get_response(uri)

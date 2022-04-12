#!/usr/bin/env ruby

require 'uri'
require 'net/http'

puts "Cleaning old sessions..."

uri = URI('https://kyrgyzpassport.herokuapp.com/')
res = Net::HTTP.get_response(uri)
puts res.body if res.is_a?(Net::HTTPSuccess)
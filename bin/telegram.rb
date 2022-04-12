#!/usr/bin/env ruby

require 'uri'
require 'net/http'

puts "Cleaning old sessions..."

uri = URI('https://kyrgyzpassport.herokuapp.com/telegram')
res = Net::HTTP.get_response(uri)

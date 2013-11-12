#!/usr/bin/env ruby

require 'json'
require 'csv'
require "open-uri"
require 'net/http'

input_filename = "img_urls.txt"

output_dir = "styles"

input_urls = File.open(input_filename,'r').read.split("\n")

puts input_urls.size

input_urls.each do |url|
  puts url
  name = File.basename(url)

  puts name
  output_filename = "#{output_dir}/#{name}"

  begin
    File.open(output_filename, 'wb') do |fo|
      fo.write open(url).read
    end
  rescue
  end

end

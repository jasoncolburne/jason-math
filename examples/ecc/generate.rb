#!/usr/bin/env ruby

if ARGV.count != 1
  puts 'Usage:'
  puts '  ./generate.rb <curve>'
  puts
  puts '$ ./generate.rb secp384r1 > keypair.json'

  exit 1
end

require './ecc'
require 'json'

curve = ARGV.first
service = CurveService.new(curve)
keypair = service.generate_keypair
puts JSON.dump(keypair)

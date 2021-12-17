#!/usr/bin/env ruby
# frozen_string_literal: true

if ARGV.count != 2
  puts 'Usage:'
  puts '  ./sign.rb <curve> <private key>'
  puts
  puts "$ cat ~/image.png | shasum -a 384 -b | cut -d \" \" -f1 | ./sign.rb secp384r1 $(cat keypair.json | jq -Mr '.private_key') > signature.json"
end

require './ecc'
require 'json'

curve = ARGV.first
private_key = ARGV.last
digest = $stdin.readline

service = CurveService.new(curve)
signature = service.sign(digest, private_key)

puts JSON.dump({ signature: signature })

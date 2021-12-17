#!/usr/bin/env ruby
# frozen_string_literal: true

if ARGV.count != 2
  puts 'Usage:'
  puts '  ./encrypt.rb <curve> <public key>'
  puts
  puts "$ echo -n 'Some text to encrypt' | ./encrypt.rb secp384r1 $(cat keypair.json | jq -Mr '.public_key') > encrypted.json"
end

require './ecc'
require 'json'

curve = ARGV.first
public_key = ARGV.last
plaintext = $stdin.readline

service = CurveService.new(curve)
ciphertext = service.encrypt(plaintext, public_key)

puts JSON.dump({ ciphertext: ciphertext })

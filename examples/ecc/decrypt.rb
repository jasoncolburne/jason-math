#!/usr/bin/env ruby

if ARGV.count != 2
  puts "Usage:"
  puts "  ./decrypt.rb <curve> <private key>"
  puts
  puts "$ cat encrypted.json | jq -Mr '.ciphertext' | ./decrypt.rb secp384r1 $(cat keypair.json | jq -Mr '.private_key') > decrypted.json"
end

require './ecc'
require 'json'

curve = ARGV.first
private_key = ARGV.last
ciphertext = STDIN.readline

service = CurveService.new(curve)
plaintext = service.decrypt(ciphertext, private_key)

puts JSON.dump({ plaintext: plaintext })

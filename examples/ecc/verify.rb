#!/usr/bin/env ruby

if ARGV.count != 3
  puts 'Usage:'
  puts '  ./verify.rb <curve> <public key> <signature>'
  puts
  puts "$ cat ~/image.png | shasum -a 384 -b | cut -d \" \" -f1 | ./verify.rb secp384r1 $(cat keypair.json | jq -Mr '.public_key') $(cat signature.json | jq -Mr '.signature')"
end

require './ecc'
require 'json'

curve = ARGV.shift
public_key = ARGV.shift
signature = ARGV.shift
digest = STDIN.readline

service = CurveService.new(curve)
verified = service.verify(digest, public_key, signature)

exit 0 if verified

puts '[!] Failed to verify'
exit 1

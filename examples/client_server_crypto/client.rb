#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'jason/math'
require 'securerandom'

socket = TCPSocket.new('0.0.0.0', ARGV.first || 1337)
curve = :secp384r1

ecc = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve.new(curve)
my_private_key = SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n
ecc.private_key = my_private_key
my_public_key = ecc.generate_public_key!

data = socket.recv(96 + 16 + 96)
payload = data[0..111]
initialization_vector = data[96..111]

signature = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(data[112..207])
sha = Jason::Math::Cryptography::Digest::SecureHashAlgorithm.new(:'3_384')
digest = sha.digest(payload).byte_string_to_integer
ecc.public_key = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(File.read('./server.pub').b)
raise "could not verify server signature" unless ecc.verify(digest, signature)
puts "verified server signature"

puts "received public key: #{data[0..95].byte_string_to_hex}"
partner_public_key = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(data[0..95])
payload = my_public_key.to_byte_string(48)
digest = sha.digest(payload).byte_string_to_integer
ecc.private_key = File.read('./client.key').b.byte_string_to_integer
signature = ecc.sign(digest, SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n).to_byte_string(48)
socket.write(payload + signature)

secret = ecc.compute_secret(my_private_key, partner_public_key)
secret = (secret.x ^ secret.y).to_byte_string.rjust(48, "\x00")
puts "computed shared secret: #{secret.byte_string_to_hex}"
key = secret[0..23] ^ secret[24..47]
puts "derived aes-gcm key: #{key.byte_string_to_hex}"
aes = Jason::Math::Cryptography::SymmetricKey::AdvancedEncryptionStandard.new(:gcm_192, key)

puts "using initialization vector: #{initialization_vector.byte_string_to_hex}"
aes.initialization_vector = initialization_vector

loop do
  payload = socket.recv(4096)
  cipher_text = payload[0..(payload.length - 17)]
  tag = payload[-16..]
  clear_text = aes.decrypt(cipher_text, '', tag)
  print clear_text

  clear_text = $stdin.gets
  cipher_text, tag = aes.encrypt(clear_text, '')
  socket.write(cipher_text + tag)
end

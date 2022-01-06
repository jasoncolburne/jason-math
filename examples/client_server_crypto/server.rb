#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'jason/math'
require 'securerandom'
require 'socket'

server = TCPServer.new(ARGV[0] || 1337)
curve = :secp384r1

loop do
  client = server.accept

  ecc = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve.new(curve)
  my_private_key = SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n
  ecc.private_key = my_private_key
  my_public_key = ecc.generate_public_key!

  client.write(my_public_key.to_hex(96))
  data = client.recv(192)

  puts "received public key: #{data}"
  partner_public_key = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.from_hex(data, 96)
  secret = ecc.compute_secret(my_private_key, partner_public_key)
  secret = (secret.x ^ secret.y).to_byte_string.rjust(48, "\x00")
  puts "computed shared secret: #{secret.byte_string_to_hex}"
  key = secret[0..23] ^ secret[24..47]
  puts "derived aes-gcm key: #{key.byte_string_to_hex}"
  aes = Jason::Math::Cryptography::SymmetricKey::AdvancedEncryptionStandard.new(:gcm_192, key)
  initialization_vector = SecureRandom.random_bytes(12) + "\x00" * 4
  puts "using initialization vector: #{initialization_vector.byte_string_to_hex}"
  aes.initialization_vector = initialization_vector

  client.write(initialization_vector)

  loop do
    clear_text = $stdin.gets
    cipher_text, tag = aes.encrypt(clear_text, '')
    client.write(cipher_text + tag)

    payload = client.recv(4096)
    cipher_text = payload[0..(payload.length - 17)]
    tag = payload[-16..]
    clear_text = aes.decrypt(cipher_text, '', tag)
    print clear_text
  end

  client.close
end

server.close
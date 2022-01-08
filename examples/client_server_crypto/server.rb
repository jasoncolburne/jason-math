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
  my_private_ecdh_key = SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n
  ecc.private_key = my_private_ecdh_key
  my_public_ecdh_key = ecc.generate_public_key!
  initialization_vector = SecureRandom.random_bytes(12) + "\x00" * 4
  payload = my_public_ecdh_key.to_byte_string(48) + initialization_vector

  sha = Jason::Math::Cryptography::Digest::SecureHashAlgorithm.new(:'3_384')
  digest = sha.digest(payload).byte_string_to_integer
  ecc.private_key = File.read('./server.key').b.byte_string_to_integer
  signature = ecc.sign(
    digest, SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n
  ).to_byte_string(48)

  client.write(payload.b + signature.b)
  data = client.recv(192)

  signature = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(data[96..191])
  digest = sha.digest(data[0..95]).byte_string_to_integer
  ecc.public_key = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(File.read('./client.pub').b)
  raise "could not verify client signature" unless ecc.verify(digest, signature)
  puts "verified client signature"

  puts "received public key: #{data[0..95].byte_string_to_hex}"
  partner_public_ecdh_key = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(data[0..95])
  secret = ecc.compute_secret(my_private_ecdh_key, partner_public_ecdh_key)
  secret = (secret.x ^ secret.y).to_byte_string.rjust(48, "\x00")
  puts "computed shared secret: #{secret.byte_string_to_hex}"
  key = secret[0..23] ^ secret[24..47]
  puts "derived aes-gcm key: #{key.byte_string_to_hex}"
  aes = Jason::Math::Cryptography::SymmetricKey::AdvancedEncryptionStandard.new(:gcm_192, key)
  puts "using initialization vector: #{initialization_vector.byte_string_to_hex}"
  aes.initialization_vector = initialization_vector

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

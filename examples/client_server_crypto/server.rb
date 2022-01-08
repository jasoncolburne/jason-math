#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'jason/math'
require 'securerandom'
require 'socket'

# DEBUG=1 ./server.rb # to see the ciphertext
# ctrl-d to end a session, ctrl-c to exit

DEBUG = !!ENV['DEBUG']
Cryptography = Jason::Math::Cryptography

server = TCPServer.new(ARGV[0] || 1337)
curve = :secp384r1

# we'll pretend we have a secure way of getting this key
class SecretManager
  def self.[](label)
    raise "unexpected label" unless label == :server_signing_key

    File.read('./server.key').b.byte_string_to_integer
  end
end

loop do
  begin
    client = server.accept
  rescue Interrupt
    puts
    break
  end

  ecc = Cryptography::AsymmetricKey::EllipticCurve.new(curve)
  my_private_ecdh_key = SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n
  ecc.private_key = my_private_ecdh_key
  my_public_ecdh_key = ecc.generate_public_key!
  initialization_vector = SecureRandom.random_bytes(12) + "\x00" * 4
  payload = my_public_ecdh_key.to_byte_string(48) + initialization_vector

  sha = Cryptography::Digest::SecureHashAlgorithm.new(:'3_384')
  digest = sha.digest(payload).byte_string_to_integer
  ecc.private_key = SecretManager[:server_signing_key]
  signature = ecc.sign(
    digest, SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n
  ).to_byte_string(48)

  client.write(payload.b + signature.b)
  data = client.recv(192)

  signature = Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(data[96..191])
  digest = sha.digest(data[0..95]).byte_string_to_integer
  ecc.public_key = Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(File.read('./client.pub').b)

  if !ecc.verify(digest, signature)
    puts "could not verify client signature"
    exit(1)
  end

  puts "verified client signature"

  puts "received public key: #{data[0..95].byte_string_to_hex}"
  partner_public_ecdh_key = Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(data[0..95])
  secret = ecc.compute_secret(my_private_ecdh_key, partner_public_ecdh_key)
  secret = (secret.x ^ secret.y).to_byte_string.rjust(48, "\x00")
  puts "computed shared secret: #{secret.byte_string_to_hex}" if DEBUG
  key = secret[0..23] ^ secret[24..47]
  puts "derived aes-gcm key: #{key.byte_string_to_hex}" if DEBUG
  aes = Cryptography::SymmetricKey::AdvancedEncryptionStandard.new(:gcm_192, key)
  puts "using initialization vector: #{initialization_vector.byte_string_to_hex}"
  aes.initialization_vector = initialization_vector

  puts

  loop do
    print 'server> '
    clear_text = $stdin.gets
    if clear_text.nil?
      puts
      break
    end

    cipher_text, tag = aes.encrypt(clear_text, '')
    client.write(cipher_text + tag)
    puts (cipher_text + tag).byte_string_to_hex if DEBUG

    payload = client.recv(4096)
    break if payload.empty?

    puts payload.byte_string_to_hex if DEBUG

    cipher_text = payload[0..-17]
    tag = payload[-16..]
    clear_text = aes.decrypt(cipher_text, '', tag)

    print 'client: '
    print clear_text
  end

  puts
  puts '----------------------------------------------------------------------'
  puts
  client.close
end

server.close

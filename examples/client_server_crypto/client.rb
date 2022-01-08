#!/usr/bin/env ruby
# frozen_string_literal: true

require 'io/console'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'
require 'securerandom'

# DEBUG=1 ./client.rb # to see the ciphertext
# ctrl-d to end your session

DEBUG = !!ENV['DEBUG']
Cryptography = Jason::Math::Cryptography

password = IO::console.getpass 'password: '
data = File.read('./client.key').b

salt = data[0..15]
initialization_vector = data[16..31]
ciphered_private_key = data[32..-17]
tag = data[-16..]

puts 'deriving storage key... (the password is "password")'
# Note - these settings for Argon are not sufficient for real use, but the native implementation is slow
argon = Cryptography::KeyStretching::Argon2.new(1, 32, 16384, 1)
key = argon.stretch(password, salt)
aes = Cryptography::SymmetricKey::AdvancedEncryptionStandard.new(:gcm_256, key)
aes.initialization_vector = initialization_vector
begin
  client_private_key = aes.decrypt(ciphered_private_key, '', tag).byte_string_to_integer
rescue RuntimeError
  puts 'could not decrypt data (bad password or corrupt file)'
  exit(1)
end

socket = TCPSocket.new('0.0.0.0', ARGV.first || 1337)
curve = :secp384r1

ecc = Cryptography::AsymmetricKey::EllipticCurve.new(curve)
my_private_key = SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n
ecc.private_key = my_private_key
my_public_key = ecc.generate_public_key!

data = socket.recv(96 + 16 + 96)
payload = data[0..111]
initialization_vector = data[96..111]

signature = Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(data[112..207])
sha = Cryptography::Digest::SecureHashAlgorithm.new(:'3_384')
digest = sha.digest(payload).byte_string_to_integer
ecc.public_key = Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(File.read('./server.pub').b)

if !ecc.verify(digest, signature)
  puts "could not verify server signature"
  exit(2)
end

puts "verified server signature"

puts "received public key: #{data[0..95].byte_string_to_hex}"
partner_public_key = Cryptography::AsymmetricKey::EllipticCurve::Point.from_byte_string(data[0..95])
payload = my_public_key.to_byte_string(48)
digest = sha.digest(payload).byte_string_to_integer
ecc.private_key = client_private_key
signature = ecc.sign(digest, SecureRandom.random_bytes(48).byte_string_to_integer % ecc.n).to_byte_string(48)
socket.write(payload + signature)

secret = ecc.compute_secret(my_private_key, partner_public_key)
secret = (secret.x ^ secret.y).to_byte_string.rjust(48, "\x00")
puts "computed shared secret: #{secret.byte_string_to_hex}"
key = secret[0..23] ^ secret[24..47]
puts "derived aes-gcm key: #{key.byte_string_to_hex}"
aes = Cryptography::SymmetricKey::AdvancedEncryptionStandard.new(:gcm_192, key)

puts "using initialization vector: #{initialization_vector.byte_string_to_hex}"
aes.initialization_vector = initialization_vector

puts

loop do
  payload = socket.recv(4096)
  break if payload.empty?
  puts payload.byte_string_to_hex if DEBUG

  cipher_text = payload[0..- 17]
  tag = payload[-16..]
  clear_text = aes.decrypt(cipher_text, '', tag)

  print 'server: '
  print clear_text

  print 'client> '
  clear_text = $stdin.gets
  if clear_text.nil?
    puts
    break
  end

  cipher_text, tag = aes.encrypt(clear_text, '')
  socket.write(cipher_text + tag)
  puts (cipher_text + tag).byte_string_to_hex if DEBUG
end

socket.close

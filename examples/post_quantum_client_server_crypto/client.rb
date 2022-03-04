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
ciphered_client_private_key = data[32..-17]
tag = data[-16..]

puts 'deriving storage key... (the password is "password")'
# Note - these settings for Argon are not sufficient for real use, but the ruby implementation is slow
argon = Cryptography::KeyStretching::Argon2.new(1, 32, 16384, 1)
key = argon.stretch(password, salt)
aes = Cryptography::SymmetricKey::AdvancedEncryptionStandard.new(:gcm_256, key)
aes.initialization_vector = initialization_vector
begin
  client_private_key = aes.decrypt(ciphered_client_private_key, '', tag)
rescue RuntimeError
  puts 'could not decrypt data (bad password or corrupt file)'
  exit(1)
end

socket = TCPSocket.new('0.0.0.0', ARGV.first || 1337)
params = :sntrup1277 # should have used sntrup1013 to better match aes-192 @ post quantum levels

sntrup = Cryptography::KeyEncapsulation::StreamlinedNTRUPrime.new(params, client_private_key)

data = socket.recv(4096)
server_generated_session_key_component = sntrup.decapsulate(data)

puts "decapsulated server generated session key: #{server_generated_session_key_component.byte_string_to_hex}" if DEBUG

sntrup.public_key = File.read('./server.pub').b

cipher_text, client_generated_session_key_component = sntrup.encapsulate
puts "encapsulated client generated session key: #{client_generated_session_key_component.byte_string_to_hex}" if DEBUG

initialization_vector = SecureRandom.random_bytes(16)
socket.write(initialization_vector + cipher_text)

session_key = client_generated_session_key_component ^ server_generated_session_key_component
puts "computed shared secret: #{session_key.byte_string_to_hex}" if DEBUG
key = session_key[0..23]
puts "derived aes-gcm key: #{key.byte_string_to_hex}" if DEBUG
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

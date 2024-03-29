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
params = :sntrup1277

# we'll pretend we have a secure way of getting this key
class SecretManager
  def self.[](label)
    raise "unexpected label" unless label == :sntrup_private_key

    @sntrup_private_key ||= File.read('./server.key').b
  end
end

sntrup = Cryptography::KeyEncapsulation::StreamlinedNTRUPrime.new(params)
client_public_key = File.read('./client.pub').b

loop do
  begin
    client = server.accept
  rescue Interrupt
    puts
    break
  end

  sntrup.public_key = client_public_key
  cipher_text, server_generated_session_key_component = sntrup.encapsulate
  puts "encapsulated server generated session key: #{server_generated_session_key_component.byte_string_to_hex}" if DEBUG

  client.write(cipher_text)
  data = client.recv(4096)

  initialization_vector = data[0..15]
  cipher_text = data[16..]

  sntrup.private_key = SecretManager[:sntrup_private_key]
  client_generated_session_key_component = sntrup.decapsulate(cipher_text)

  puts "decapsulated client generated session key: #{client_generated_session_key_component.byte_string_to_hex}" if DEBUG

  session_key = server_generated_session_key_component ^ client_generated_session_key_component
  key = session_key[0..23]
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

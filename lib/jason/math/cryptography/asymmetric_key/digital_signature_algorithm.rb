# frozen_string_literal: true

require 'set'

module Jason
  module Math
    module Cryptography
      module AsymmetricKey
        # DSA
        class DigitalSignatureAlgorithm
          # rubocop:disable Naming/VariableNumber
          HASH_ALGORITHMS = {
            sha_1: {
              class: Digest::SecureHashAlgorithm,
              mode: :'1'
            }.freeze,
            sha_224: {
              class: Digest::SecureHashAlgorithm,
              mode: :'224'
            }.freeze,
            sha_256: {
              class: Digest::SecureHashAlgorithm,
              mode: :'256'
            }.freeze,
            sha_384: {
              class: Digest::SecureHashAlgorithm,
              mode: :'384'
            }.freeze,
            sha_512: {
              class: Digest::SecureHashAlgorithm,
              mode: :'512'
            }.freeze,
            sha_512_224: {
              class: Digest::SecureHashAlgorithm,
              mode: :'512_224'
            }.freeze,
            sha_512_256: {
              class: Digest::SecureHashAlgorithm,
              mode: :'512_256'
            }.freeze,
            sha_3_224: {
              class: Digest::SecureHashAlgorithm,
              mode: :'3_224'
            }.freeze,
            sha_3_256: {
              class: Digest::SecureHashAlgorithm,
              mode: :'3_256'
            }.freeze,
            sha_3_384: {
              class: Digest::SecureHashAlgorithm,
              mode: :'3_384'
            }.freeze,
            sha_3_512: {
              class: Digest::SecureHashAlgorithm,
              mode: :'3_512'
            }.freeze,
            blake2b: {
              class: Digest::Blake,
              mode: :'2b'
            }.freeze
          }.freeze
          # rubocop:enable Naming/VariableNumber

          # all length values in bytes
          PARAMETERS = {
            '1024': {
              key_length: 128,
              modulus_length: 20
            }.freeze,
            '2048': {
              key_length: 256,
              modulus_length: 28
            }.freeze,
            '3072': {
              key_length: 384,
              modulus_length: 32
            }.freeze
          }.freeze

          attr_reader :used_k_values

          def initialize( # rubocop:disable Metrics/ParameterLists
            hash_algorithm,
            parameter_set,
            p = nil, q = nil, g = nil,
            x = nil, y = nil,
            used_k_values = [],
            validate_parameters: true
          )
            parameters = PARAMETERS[parameter_set]
            parameters.each_pair do |key, value|
              instance_variable_set("@#{key}", value)
            end

            if validate_parameters
              raise 'invalid parameters' if (g % p).zero? || g % p == 1
              raise 'insecure parameters' unless p.to_byte_string.length == @key_length
            end

            @p = p
            @q = q
            @g = g
            @x = x
            @y = y

            @used_k_values = used_k_values.to_set

            @digest = HASH_ALGORITHMS[hash_algorithm][:class].new(HASH_ALGORITHMS[hash_algorithm][:mode])
          end

          def generate_parameters!
            @q = NumberTheory.large_random_prime(@modulus_length)

            factor = (2**(@key_length * 8 - 1)) / @q
            @p = nil
            loop do
              @p = @q * factor + 1
              factor += 1
              break if NumberTheory.probably_prime?(@p)
            end

            @g = nil
            loop do
              h = SecureRandom.random_number(2..(@p - 2))
              @g = NumberTheory.modular_exponentiation(h, (@p - 1) / @q, @p)
              break unless @g == 1
            end

            [@p, @q, @g]
          end

          def generate_keypair!
            @x = SecureRandom.random_number(1..(@q - 1))
            @y = NumberTheory.modular_exponentiation(@g, @x, @p)
            @used_k_values = Set[]

            [@x, @y]
          end

          def sign(message)
            r = nil
            s = nil
            m = @digest.digest(message)[0..(@modulus_length - 1)].byte_string_to_integer

            loop do
              k = SecureRandom.random_number(1..(@q - 1))
              next if @used_k_values.include?(k)

              r = NumberTheory.modular_exponentiation(@g, k, @p) % @q
              next if r.zero?

              s = (NumberTheory.modular_inverse(k, @q) * (m + @x * r)) % @q
              next if s.zero?

              @used_k_values << k
              break
            end

            [r, s]
          end

          def verify(message, r, s)
            return false if r >= @q || r <= 0
            return false if s >= @q || s <= 0

            w = NumberTheory.modular_inverse(s, @q)
            m = @digest.digest(message)[0..(@modulus_length - 1)].byte_string_to_integer
            u1 = (m * w) % @q
            u2 = (r * w) % @q
            v = ((NumberTheory.modular_exponentiation(@g, u1, @p) *
                  NumberTheory.modular_exponentiation(@y, u2, @p)) % @p) % @q
            v == r
          end
        end
      end
    end
  end
end

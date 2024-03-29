# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      module AsymmetricKey
        # RSA - do not use, generated keys may not be secure
        class RivestShamirAdleman
          attr_writer :modulus, :private_key, :public_key

          PARAMETERS = {
            '512': {
              key_length: 64 # in bytes
            }.freeze,
            '1024': { # 80 bits of security
              key_length: 128 # in bytes
            }.freeze,
            '2048': { # 112 bits of security
              key_length: 256 # in bytes
            }.freeze,
            '3072': { # 128 bits of security
              key_length: 384 # in bytes
            }.freeze,
            '4096': { # 152 bits of security
              key_length: 512 # in bytes
            }.freeze,
            '7680': { # 192 bits of security
              key_length: 960 # in bytes
            }.freeze,
            '15360': { # 256 bits of security
              key_length: 1920 # in bytes
            }.freeze
          }.freeze

          def initialize(algorithm, modulus = nil, private_key = nil, public_key = 65_537)
            @algorithm = algorithm
            @modulus = modulus unless modulus.nil?
            @private_key = private_key unless private_key.nil?
            @public_key = public_key unless public_key.nil?

            parameters = PARAMETERS[@algorithm]
            parameters.each_pair { |key, value| instance_variable_set("@#{key}", value) }
          end

          def encrypt(clear_text)
            raise 'clear text must be less than modulus' unless clear_text < @modulus

            NumberTheory.modular_exponentiation(clear_text, @public_key, @modulus)
          end

          def decrypt(cipher_text)
            # it doesn't actually matter if the cipher text is less than the modulus
            # but it likely indicates a programmer error.
            warn('warning: cipher text was not less than modulus') unless cipher_text < @modulus

            NumberTheory.modular_exponentiation(cipher_text, @private_key, @modulus)
          end

          def sign(digest)
            NumberTheory.modular_exponentiation(digest, @private_key, @modulus)
          end

          def verify(digest, signature)
            digest % @modulus == NumberTheory.modular_exponentiation(signature, @public_key, @modulus)
          end

          def generate_keypair!(update_instance: true)
            loop do
              p, q = 2.times.map { NumberTheory.large_random_prime(@key_length / 2) }
              n = p * q
              l = NumberTheory.lcm(p - 1, q - 1)

              next unless NumberTheory.co_prime?([l, @public_key])

              d = NumberTheory.modular_inverse(@public_key, l)

              if update_instance
                @private_key = d
                @modulus = n
              end

              return [n, d, @public_key]
            end
          end
        end
      end
    end
  end
end

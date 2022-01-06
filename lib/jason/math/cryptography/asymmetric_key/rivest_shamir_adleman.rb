# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      module AsymmetricKey
        # RSA
        class RivestShamirAdleman
          attr_writer :modulus, :private_key, :public_key

          PARAMETERS = {
            '1024': {
              key_length: 128 # in bytes
            }.freeze,
            '2048': {
              key_length: 256 # in bytes
            }.freeze,
            '4096': {
              key_length: 512 # in bytes
            }.freeze
          }.freeze

          def initialize(algorithm, modulus = nil, private_key = nil, public_key = 65_537)
            @algorithm = algorithm
            @modulus = modulus unless modulus.nil?
            @private_key = private_key unless private_key.nil?
            @public_key = public_key

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

          def generate_keypair(update_instance: true) # rubocop:disable Metrics/MethodLength
            loop do
              primes = []

              prime_candidate = nil
              while primes.length < 2
                if prime_candidate.nil?
                  candidate = SecureRandom.random_bytes(@key_length / 2)
                  candidate[0] = Utility.or(candidate[0], "\x80") # make it big
                  candidate[-1] = Utility.or(candidate[-1], "\x01") # make it odd

                  prime_candidate = candidate.byte_string_to_integer
                else
                  prime_candidate += 2
                end

                next unless NumberTheory.probably_prime?(prime_candidate)

                primes << prime_candidate
              end

              p, q = primes
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

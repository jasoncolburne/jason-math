require 'jason/math/cryptography/advanced_encryption_standard'
require 'jason/math/cryptography/elliptic_curve'
require 'jason/math/cryptography/exclusive_or'

module Jason
  module Math
    module Cryptography
      def self.hamming_distance(a, b)
        raise "Cannot compute hamming distance if lengths differ" unless a.length == b.length
        Jason::Math::Utility.xor(a, b).unpack('B*').first.count('1')
      end

      class Cipher
        ALGORITHMS = {
          aes_128_ecb: {
            class: AdvancedEncryptionStandard,
            mode: :ecb_128,
          }.freeze,
          aes_192_ecb: {
            class: AdvancedEncryptionStandard,
            mode: :ecb_192,
          }.freeze,
          aes_256_ecb: {
            class: AdvancedEncryptionStandard,
            mode: :ecb_256,
          }.freeze,
        }.freeze

        def initialize(algorithm, key, initialization_vector = nil)
          raise "Unsupported algorithm" unless ALGORITHMS.keys.include?(algorithm)

          details = ALGORITHMS[algorithm]
          @cipher = details[:class].new(details[:mode], key, initialization_vector)
        end

        def encrypt(clear_text)
          @cipher.encrypt(clear_text)
        end

        def decrypt(cipher_text)
          @cipher.decrypt(cipher_text)
        end
      end
    end
  end
end

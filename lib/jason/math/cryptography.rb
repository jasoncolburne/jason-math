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
          aes_128_cbc: { class: AdvancedEncryptionStandard, mode: :cbc_128 }.freeze,
          aes_192_cbc: { class: AdvancedEncryptionStandard, mode: :cbc_192 }.freeze,
          aes_256_cbc: { class: AdvancedEncryptionStandard, mode: :cbc_256 }.freeze,
          aes_128_cfb: { class: AdvancedEncryptionStandard, mode: :cfb_128 }.freeze,
          aes_192_cfb: { class: AdvancedEncryptionStandard, mode: :cfb_192 }.freeze,
          aes_256_cfb: { class: AdvancedEncryptionStandard, mode: :cfb_256 }.freeze,
          aes_128_ctr: { class: AdvancedEncryptionStandard, mode: :ctr_128 }.freeze,
          aes_192_ctr: { class: AdvancedEncryptionStandard, mode: :ctr_192 }.freeze,
          aes_256_ctr: { class: AdvancedEncryptionStandard, mode: :ctr_256 }.freeze,
          aes_128_ecb: { class: AdvancedEncryptionStandard, mode: :ecb_128 }.freeze,
          aes_192_ecb: { class: AdvancedEncryptionStandard, mode: :ecb_192 }.freeze,
          aes_256_ecb: { class: AdvancedEncryptionStandard, mode: :ecb_256 }.freeze,
          aes_128_ofb: { class: AdvancedEncryptionStandard, mode: :ofb_128 }.freeze,
          aes_192_ofb: { class: AdvancedEncryptionStandard, mode: :ofb_192 }.freeze,
          aes_256_ofb: { class: AdvancedEncryptionStandard, mode: :ofb_256 }.freeze,
        }.freeze

        def initialize(algorithm, key, use_openssl = false)
          raise "Unsupported algorithm" unless ALGORITHMS.keys.include?(algorithm)

          details = ALGORITHMS[algorithm]
          @cipher = details[:class].new(details[:mode], key, use_openssl)
        end

        def encrypt(clear_text, initialization_vector)
          @cipher.encrypt(clear_text, initialization_vector)
        end

        def decrypt(cipher_text, initialization_vector)
          @cipher.decrypt(cipher_text, initialization_vector)
        end

        def generate_nonce
          @cipher.generate_nonce
        end

        def self.generate_key(algorithm)
          raise "Unsupported algorithm" unless ALGORITHMS.keys.include?(algorithm)

          details = ALGORITHMS[algorithm]
          details[:class].generate_key(details[:mode])
        end
      end
    end
  end
end

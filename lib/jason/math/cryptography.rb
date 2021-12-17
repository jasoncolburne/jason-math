# frozen_string_literal: true

require 'jason/math/cryptography/advanced_encryption_standard'
require 'jason/math/cryptography/elliptic_curve'
require 'jason/math/cryptography/exclusive_or'

module Jason
  module Math
    module Cryptography
      def self.hamming_distance(a, b)
        raise 'Cannot compute hamming distance if lengths differ' unless a.length == b.length

        Utility.xor(a, b).unpack1('B*').count('1')
      end

      class PKCS7
        def self.pad(data, block_size)
          length = data.length
          total_length = (length / block_size + 1) * block_size
          padding = total_length - length
          (data + ([padding] * padding).pack('C*')).b
        end

        def self.pad_block(data, block_size)
          padding = block_size - data.length
          padding.zero? ? data : (data + ([padding] * padding).pack('C*')).b
        end

        def self.strip(data, block_size)
          padding = validate(data, block_size)
          data[0..(-padding - 1)]
        end

        def self.validate(data, block_size)
          raise 'Data length must be a multiple of block_size' unless (data.length % block_size).zero?

          padding = data[-1].ord

          raise 'Invalid padding' if padding > block_size || padding.zero?
          raise 'Invalid padding' unless data[-padding..] == ([padding] * padding).pack('C*')

          padding
        end
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
          aes_256_ofb: { class: AdvancedEncryptionStandard, mode: :ofb_256 }.freeze
        }.freeze

        def initialize(algorithm, key, use_openssl = false)
          raise 'Unsupported algorithm' unless ALGORITHMS.keys.include?(algorithm)

          details = ALGORITHMS[algorithm]
          @cipher = details[:class].new(details[:mode], key, use_openssl)
        end

        def encrypt(clear_text, initialization_vector = nil)
          @cipher.encrypt(clear_text, initialization_vector)
        end

        def decrypt(cipher_text, initialization_vector = nil, strip_padding = true)
          @cipher.decrypt(cipher_text, initialization_vector, strip_padding)
        end

        def generate_nonce
          @cipher.generate_nonce
        end

        def self.generate_key(algorithm)
          raise 'Unsupported algorithm' unless ALGORITHMS.keys.include?(algorithm)

          details = ALGORITHMS[algorithm]
          details[:class].generate_key(details[:mode])
        end

        def self.split_into_blocks(data, block_size)
          block_count = (data.length.to_f / block_size).ceil
          (0..(block_count - 1)).map do |i|
            data[(i * block_size)..((i + 1) * block_size - 1)]
          end
        end

        def self.block_size(encryptor, maximum_block_size = 128)
          current_length = encryptor.encrypt('A'.b).length

          (2..(maximum_block_size + 1)).each do |i|
            previous_length = current_length
            current_length = encryptor.encrypt('A'.b * i).length
            return current_length - previous_length if current_length != previous_length
          end

          raise "Block size appears to be larger than #{maximum_block_size}"
        end

        def self.detect_ecb?(cipher_text, block_size = 16)
          indicies = (0..cipher_text.length).step(block_size).to_a

          blocks = (0..(indicies.count - 2)).map do |index|
            cipher_text[indicies[index]..(indicies[index + 1] - 1)]
          end

          blocks.size != blocks.to_set.size
        end

        def self.count_clear_text_extra_bytes(encryptor, block_size)
          current_length = encryptor.encrypt('').size
          (1..block_size).each do |i|
            previous_length = current_length
            current_length = encryptor.encrypt('A'.b * i).size
            return previous_length - i if current_length != previous_length
          end

          raise 'Could not count clear text extra bytes'
        end

        def self.count_clear_text_prefix_bytes(encryptor, block_size)
          current_blocks = split_into_blocks(encryptor.encrypt(''), block_size)
          first_difference = nil
          (1..(block_size + 1)).each do |i|
            previous_blocks = current_blocks
            current_blocks = split_into_blocks(encryptor.encrypt('A'.b * i), block_size)
            changed = false
            previous_blocks.each_with_index do |block, index|
              next unless block != current_blocks[index]

              if first_difference.nil?
                first_difference = index
              elsif first_difference != index
                changed = true
              end

              break
            end

            return first_difference * block_size + (1 - i) % block_size if changed
          end

          raise 'Could not count clear text prefix bytes'
        end
      end
    end
  end
end

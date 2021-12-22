# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      # An abstraction of ciphers
      class Cipher
        # rubocop:disable Naming/VariableNumber
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
          xor_repeated_key: { class: ExclusiveOrCipher, mode: :repeated_key }.freeze,
          xor_mt19937_block: { class: ExclusiveOrCipher, mode: :mt19937_block }.freeze,
          xor_mt19937_64_block: { class: ExclusiveOrCipher, mode: :mt19937_64_block }.freeze,
          xor_mt19937_stream: { class: ExclusiveOrCipher, mode: :mt19937_64_stream }.freeze,
          xor_mt19937_64_stream: { class: ExclusiveOrCipher, mode: :mt19937_64_stream }.freeze
        }.freeze
        # rubocop:enable Naming/VariableNumber

        def initialize(algorithm, key, use_openssl: false)
          raise 'Unsupported algorithm' unless ALGORITHMS.keys.include?(algorithm)

          details = ALGORITHMS[algorithm]
          @cipher = details[:class].new(details[:mode], key, use_openssl: use_openssl)
        end

        def initialization_vector=(initialization_vector)
          @cipher.initialization_vector = initialization_vector
        end

        def encrypt(clear_text)
          @cipher.encrypt(clear_text)
        end

        def decrypt(cipher_text, strip_padding: true)
          @cipher.decrypt(cipher_text, strip_padding: strip_padding)
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

        def self.block_size(cryptor, maximum_block_size = 128)
          current_length = cryptor.encrypt('A'.b).length

          (2..(maximum_block_size + 1)).each do |i|
            previous_length = current_length
            current_length = cryptor.encrypt('A'.b * i).length
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

        def self.count_clear_text_extra_bytes(cryptor, block_size)
          current_length = cryptor.encrypt('').size
          (1..block_size).each do |i|
            previous_length = current_length
            current_length = cryptor.encrypt('A'.b * i).size
            return previous_length - i if current_length != previous_length
          end

          raise 'Could not count clear text extra bytes'
        end

        def self.count_clear_text_prefix_bytes(cryptor, block_size)
          j_blocks = split_into_blocks(cryptor.encrypt(''), block_size)
          c_blocks = split_into_blocks(cryptor.encrypt(''), block_size)
          first_difference = nil
          (1..(block_size + 1)).each do |i|
            previous_j_blocks = j_blocks
            previous_c_blocks = c_blocks
            range = 0..(j_blocks.length - 1)
            j_blocks = split_into_blocks(cryptor.encrypt('j'.b * i), block_size)
            c_blocks = split_into_blocks(cryptor.encrypt('c'.b * i), block_size)
            changed = false
            range.each do |index|
              next unless j_blocks[index] != previous_j_blocks[index] || c_blocks[index] != previous_c_blocks[index]

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

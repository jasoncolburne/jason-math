# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      # A very simple cipher
      class ExclusiveOrCipher
        # A generic bytestream constructed atop a PRNG
        class PRNGByteStream
          def initialize(prng, bytes_per_number)
            @byte_stream = Enumerator.new do |yielder|
              loop do
                bytes = Utility.integer_to_byte_string(prng.extract_number).rjust(bytes_per_number, "\x00")
                bytes.each_char do |char|
                  yielder << char
                end
              end
            end
          end

          def take_byte
            take_bytes
          end

          def take_bytes(count = 1)
            @byte_stream.take(count).join
          end
        end

        MODES = %i[repeated_key mt19937_block mt19937_64_block mt19937_stream mt19937_64_stream].freeze

        def initialize(mode, key, use_openssl: false) # rubocop:disable Lint/UnusedMethodArgument
          raise 'Unknown mode' unless MODES.include?(mode)

          @key = key
          @mode = mode

          return if mode == :repeated_key

          mode_string = mode.to_s

          @block_size, @bit_length = mode_string.include?('64') ? [8, 64] : [4, 32]

          raise "For the MT19937 XOR cipher, use a #{@bit_length}-bit integer key" unless key.is_a? Integer
          raise "For the MT19937 XOR cipher, use a #{@bit_length}-bit integer key" unless key % 2**@bit_length == key

          mode = mode_string.chomp('_block').chomp('_stream')
          @prng = MersenneTwister19937.new(mode.to_sym, key)

          return unless mode_string.include?('stream')

          @key_stream = PRNGByteStream.new(@prng, @block_size)
        end

        def encrypt(clear_text, _ = nil)
          send(:"encrypt_#{@mode}", clear_text)
        end

        def decrypt(cipher_text, _ = nil, strip_padding: true)
          send(:"decrypt_#{@mode}", cipher_text, strip_padding: strip_padding)
        end

        def encrypt_repeated_key(clear_text)
          cipher(clear_text, @key)
        end

        def decrypt_repeated_key(cipher_text, strip_padding: false) # rubocop:disable Lint/UnusedMethodArgument
          cipher(cipher_text, @key)
        end

        def encrypt_mt19937_block(clear_text)
          padded_clear_text = PKCS7.pad(clear_text, @block_size)

          Cipher.split_into_blocks(padded_clear_text, @block_size).map do |block|
            integer_mask = @prng.extract_number
            mask = Utility.integer_to_byte_string(integer_mask).rjust(@block_size, "\x00")
            cipher(block, mask)
          end.join
        end
        alias encrypt_mt19937_64_block encrypt_mt19937_block

        def decrypt_mt19937_block(cipher_text, strip_padding: true)
          clear_text = Cipher.split_into_blocks(cipher_text, @block_size).map do |block|
            integer_mask = @prng.extract_number
            mask = Utility.integer_to_byte_string(integer_mask).rjust(@block_size, "\x00")
            cipher(block, mask)
          end.join

          if strip_padding
            PKCS7.strip(clear_text, @block_size)
          else
            clear_text
          end
        end
        alias decrypt_mt19937_64_block decrypt_mt19937_block

        def encrypt_mt19937_stream(clear_text)
          clear_text.chars.map do |char|
            cipher(char, @key_stream.take_byte)
          end.join
        end
        alias encrypt_mt19937_64_stream encrypt_mt19937_stream

        def decrypt_mt19937_stream(cipher_text)
          cipher_text.chars.map do |char|
            cipher(char, @key_stream.take_byte)
          end.join
        end
        alias decrypt_mt19937_64_stream decrypt_mt19937_stream

        def self.break_repeated_key( # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          cipher_text,
          key_length_range,
          chunks_to_scan = 4,
          keys_to_derive = 3,
          language = :english
        )
          normalized_hamming_distances_by_key_length = key_length_range.map do |key_length|
            if key_length * 4 > cipher_text.length
              raise 'Key length too long to compute hamming distance of cipher text'
            end

            distances = (0..(chunks_to_scan - 1)).map do |i|
              range_a = (key_length * i)..(key_length * (i + 1) - 1)
              range_b = (key_length * (i + 1))..(key_length * (i + 2) - 1)
              Cryptography.hamming_distance(cipher_text[range_a], cipher_text[range_b]).to_f / key_length
            end

            distances.sum.to_f / distances.count
          end.zip(key_length_range)

          lengths_to_try = normalized_hamming_distances_by_key_length.sort_by { |distance, _length| distance }
          lengths_to_try = lengths_to_try.first(keys_to_derive).map { |_distance, length| length }
          keys_by_distance = lengths_to_try.map do |key_length|
            distances = []

            key = transpose_data(cipher_text, key_length).map do |block|
              distance, characters = break_single_byte_cipher(block, language)
              raise 'Found multiple possible keys for single byte xor cipher' unless characters.count == 1

              distances << distance
              characters.first
            end.join

            [distances.sum / distances.count, key]
          end.to_h

          keys_by_distance[keys_by_distance.keys.min]
        end

        def self.break_single_byte_cipher(cipher_text, language = :english)
          keys_by_english_distance = Hash.new { |h, k| h[k] = [] }

          length = cipher_text.length
          0.upto(255) do |n|
            deciphered_data = Utility.xor((n.chr * length), cipher_text)
            distance = Utility::LanguageDetector.distance(deciphered_data, language)
            keys_by_english_distance[distance] << n.chr
          end

          minimum_distance = keys_by_english_distance.keys.min
          [minimum_distance, keys_by_english_distance[minimum_distance]]
        end

        private_class_method def self.transpose_data(data, key_length)
          return [data] if key_length == 1

          bytes = data.bytes
          0.upto(key_length - 1).map do |offset|
            i = offset

            aggregator = ''
            while i < bytes.length
              aggregator += bytes[i].chr
              i += key_length
            end

            aggregator
          end
        end

        private

        def cipher(data, key)
          key_characters = key.chars
          data.chars.map do |character|
            result = Utility.xor(character, key_characters[0])
            key_characters << key_characters.shift
            result
          end.join
        end
      end
    end
  end
end

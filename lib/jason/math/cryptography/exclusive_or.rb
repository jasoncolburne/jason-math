# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      module ExclusiveOr
        def self.cipher(data, key)
          key_characters = key.chars
          data.chars.map do |character|
            result = Utility.xor(character, key_characters[0])
            key_characters << key_characters.shift
            result
          end.join
        end

        def self.break_cipher(cipher_text, key_length_range, chunks_to_scan = 4, keys_to_derive = 3, language = :english)
          normalized_hamming_distances_by_key_length = key_length_range.map do |key_length|
            if key_length * 4 > cipher_text.length
              raise 'Key length too long to compute hamming distance of cipher text'
            end

            distances = (0..(chunks_to_scan - 1)).map do |i|
              Cryptography.hamming_distance(cipher_text[(key_length * i)..(key_length * (i + 1) - 1)],
                                            cipher_text[(key_length * (i + 1))..(key_length * (i + 2) - 1)]).to_f / key_length
            end
            distances.sum.to_f / distances.count
          end.zip(key_length_range)

          lengths_to_try = normalized_hamming_distances_by_key_length.sort_by do |distance, _length|
                             distance
                           end.first(keys_to_derive).map { |_distance, length| length }
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

        def self.transpose_data(data, key_length)
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
      end
    end
  end
end

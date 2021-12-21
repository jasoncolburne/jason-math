# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
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
    end
  end
end

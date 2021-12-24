# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      # An abstraction of digests
      class SecureHashAlgorithm
        attr_accessor :cumulative_length

        PARAMETERS = {
          '1': {
            h0: 0x67452301,
            h1: 0xEFCDAB89,
            h2: 0x98BADCFE,
            h3: 0x10325476,
            h4: 0xC3D2E1F0,
            max_integer: 2**32
          }.freeze
        }.freeze

        def initialize(algorithm)
          @algorithm = algorithm

          reset
        end

        def update(message)
          @cumulative_length += message.b.length

          to_transform = @to_transform + message
          blocks = Cipher.split_into_blocks(to_transform, 64)
          @to_transform = blocks.pop || ''
          blocks.each { |block| transform(block) }

          nil
        end

        alias << update

        def finish
          to_transform = Digest.pad(@to_transform, @cumulative_length)
          blocks = Cipher.split_into_blocks(to_transform, 64)
          blocks.each { |block| transform(block) }

          result = [@h0, @h1, @h2, @h3, @h4].pack('N*')

          reset
          result
        end

        def digest(message = '')
          update(message)
          finish
        end

        def state=(state)
          @h0, @h1, @h2, @h3, @h4 = state
        end

        private

        def reset
          @cumulative_length = 0
          @to_transform = ''.b

          parameters = PARAMETERS[@algorithm]
          parameters.each_pair { |key, value| instance_variable_set("@#{key}", value) }
        end

        def transform(block) # rubocop:disable Metrics/MethodLength
          a = @h0
          b = @h1
          c = @h2
          d = @h3
          e = @h4
          w = block.unpack('N*')

          (16..79).each do |i|
            w << Utility.rotate_left(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1)
          end

          (0..79).each do |i|
            f, k = case i
                   when 0..19
                     f = (b & c) | ((~b % 0x100000000) & d)
                     [f, 0x5a827999]
                   when 20..39
                     f = b ^ c ^ d
                     [f, 0x6ed9eba1]
                   when 40..59
                     f = (b & c) | (b & d) | (c & d)
                     [f, 0x8f1bbcdc]
                   when 60..79
                     f = b ^ c ^ d
                     [f, 0xca62c1d6]
                   end

            temp = (Utility.rotate_left(a, 5) + f + e + k + w[i]) % @max_integer
            e = d
            d = c
            c = Utility.rotate_left(b, 30)
            b = a
            a = temp
          end

          @h0 = (@h0 + a) % @max_integer
          @h1 = (@h1 + b) % @max_integer
          @h2 = (@h2 + c) % @max_integer
          @h3 = (@h3 + d) % @max_integer
          @h4 = (@h4 + e) % @max_integer
        end
      end
    end
  end
end

# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      class Digest
        # MD4 for now
        class MessageDigest
          attr_accessor :cumulative_length

          PARAMETERS = {
            '4': {
              a: 0x67452301,
              b: 0xefcdab89,
              c: 0x98badcfe,
              d: 0x10325476,
              max_integer: 2**32,
              block_size: 64
            }.freeze
          }.freeze

          def initialize(algorithm)
            @algorithm = algorithm
            reset
          end

          def update(message)
            @cumulative_length += message.b.length

            to_transform = @to_transform + message
            blocks = Cipher.split_into_blocks(to_transform, @block_size)
            @to_transform = blocks.pop || ''
            blocks.each { |block| transform(block) }

            nil
          end

          alias << update

          def finish
            to_transform = Digest.pad(@to_transform, :vax, @cumulative_length)
            blocks = Cipher.split_into_blocks(to_transform, @block_size)
            blocks.each { |block| transform(block) }

            result = [@a, @b, @c, @d].pack('V4')

            reset
            result
          end

          def digest(message = '')
            update(message)
            finish
          end

          def state=(state)
            @a, @b, @c, @d = state
          end

          private

          def reset
            @cumulative_length = 0
            @to_transform = ''.b

            parameters = PARAMETERS[@algorithm]
            parameters.each_pair { |key, value| instance_variable_set("@#{key}", value) }
          end

          def f(x, y, z)
            (x & y) | ((~x % @max_integer) & z)
          end

          def g(x, y, z)
            (x & y) | (x & z) | (y & z)
          end

          def h(x, y, z)
            x ^ y ^ z
          end

          def r(v, s)
            Utility.rotate_left(v % @max_integer, s)
          end

          def transform(block) # rubocop:disable Metrics/MethodLength
            a = @a
            b = @b
            c = @c
            d = @d

            x = block.unpack('V16')

            [0, 4, 8, 12].each do |i|
              a = r(a + f(b, c, d) + x[i], 3)
              d = r(d + f(a, b, c) + x[i + 1], 7)
              c = r(c + f(d, a, b) + x[i + 2], 11)
              b = r(b + f(c, d, a) + x[i + 3], 19)
            end

            [0, 1, 2, 3].each do |i|
              a = r(a + g(b, c, d) + x[i] + 0x5a827999, 3)
              d = r(d + g(a, b, c) + x[i + 4] + 0x5a827999, 5)
              c = r(c + g(d, a, b) + x[i + 8] + 0x5a827999, 9)
              b = r(b + g(c, d, a) + x[i + 12] + 0x5a827999, 13)
            end

            [0, 2, 1, 3].each do |i|
              a = r(a + h(b, c, d) + x[i] + 0x6ed9eba1, 3)
              d = r(d + h(a, b, c) + x[i + 8] + 0x6ed9eba1, 9)
              c = r(c + h(d, a, b) + x[i + 4] + 0x6ed9eba1, 11)
              b = r(b + h(c, d, a) + x[i + 12] + 0x6ed9eba1, 15)
            end

            @a = (@a + a) % @max_integer
            @b = (@b + b) % @max_integer
            @c = (@c + c) % @max_integer
            @d = (@d + d) % @max_integer
          end
        end
      end
    end
  end
end

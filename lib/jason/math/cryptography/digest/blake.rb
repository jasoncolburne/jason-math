# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      class Digest
        # Blake
        class Blake
          MASK32 = 0xffffffff
          MASK64 = 0xffffffffffffffff

          SIGMA = [
            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15].freeze,
            [14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3].freeze,
            [11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4].freeze,
            [7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8].freeze,
            [9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13].freeze,
            [2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9].freeze,
            [12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11].freeze,
            [13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10].freeze,
            [6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5].freeze,
            [10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0].freeze
          ].freeze

          PARAMETERS = {
            '2b': {
              h: [
                0x6a09e667f3bcc908,
                0xbb67ae8584caa73b,
                0x3c6ef372fe94f82b,
                0xa54ff53a5f1d36f1,
                0x510e527fade682d1,
                0x9b05688c2b3e6c1f,
                0x1f83d9abfb41bd6b,
                0x5be0cd19137e2179
              ].freeze,
              max_integer: 2**64,
              block_size: 128
            }.freeze
          }.freeze

          def initialize(algorithm, output_length = 64, key = '')
            raise 'Maximum key length 64 bytes' unless key.length <= 64

            @algorithm = algorithm
            @key = key
            @output_length = output_length

            reset
          end

          def update(message)
            message = @key.ljust(128, "\x00") + message if @bytes_processed.zero? && !@key.length.zero?

            to_transform = @to_transform + message
            blocks = Cipher.split_into_blocks(to_transform, @block_size)
            @to_transform = blocks.pop || ''
            blocks.each do |block|
              @bytes_processed += @block_size
              send("transform_#{@algorithm}", block)
            end

            nil
          end

          alias << update

          def finish
            blocks = Cipher.split_into_blocks(@to_transform, @block_size)
            blocks.each_with_index do |block, index|
              if index + 1 == blocks.count
                @last_block = true
                @bytes_processed += block.length
                block = block.ljust(@block_size, "\x00")
              else
                @bytes_processed += @block_size
              end

              send("transform_#{@algorithm}", block)
            end

            if @bytes_processed.zero?
              @last_block = true
              send("transform_#{@algorithm}", "\x00" * @block_size)
            end

            result = send("output_#{@algorithm}")

            reset
            result
          end

          def digest(message = '')
            update(message)
            finish
          end

          def state=(state)
            send("state_#{@algorithm}=", state)
          end

          def output_length=(output_length)
            @output_length = output_length
            reset
          end

          private

          def reset
            @bytes_processed = 0
            @last_block = false
            @to_transform = ''.b

            parameters = PARAMETERS[@algorithm]
            parameters.each_pair { |key, value| instance_variable_set("@#{key}", value) }

            @h = @h.dup
            @h[0] ^= (0x01010000 | (@key.length << 8) | (@output_length & 0xff))
          end

          def transform(block)
            v = @h + PARAMETERS[@algorithm][:h]
            v[12] ^= (@bytes_processed & 0xffffffffffffffff)
            v[13] ^= (@bytes_processed >> 64)
            v[14] ^= 0xffffffffffffffff if @last_block

            m = block.unpack('Q<16')

            (0..11).each { |i| round(v, m, SIGMA[i % 10]) }
            (0..15).each { |i| @h[i % 8] ^= v[i] }
          end

          def mix(va, vb, vc, vd, x, y, mka: false) # rubocop:disable Metrics/ParameterLists
            z = mka ? 2 * (va & MASK32) * (vb & MASK32) : 0
            va = (va + vb + x + z) % @max_integer
            vd = Utility.rotate_right(vd ^ va, 32, MASK64)

            z = mka ? 2 * (vc & MASK32) * (vd & MASK32) : 0
            vc = (vc + vd + z) % @max_integer
            vb = Utility.rotate_right(vb ^ vc, 24, MASK64)

            z = mka ? 2 * (va & MASK32) * (vb & MASK32) : 0
            va = (va + vb + y + z) % @max_integer
            vd = Utility.rotate_right(vd ^ va, 16, MASK64)

            z = mka ? 2 * (vc & MASK32) * (vd & MASK32) : 0
            vc = (vc + vd + z) % @max_integer
            vb = Utility.rotate_right(vb ^ vc, 63, MASK64)

            [va, vb, vc, vd]
          end

          def round(v, m = [0], s = [0] * 16, mka: false)
            (0..3).each do |n|
              v[n], v[n + 4], v[n + 8], v[n + 12] = mix(v[n], v[n + 4], v[n + 8], v[n + 12],
                                                        m[s[n * 2]], m[s[n * 2 + 1]], mka: mka)
            end

            v[0], v[5], v[10], v[15] = mix(v[0], v[5], v[10], v[15], m[s[8]], m[s[9]], mka: mka)
            v[1], v[6], v[11], v[12] = mix(v[1], v[6], v[11], v[12], m[s[10]], m[s[11]], mka: mka)
            v[2], v[7], v[8], v[13] = mix(v[2], v[7], v[8], v[13], m[s[12]], m[s[13]], mka: mka)
            v[3], v[4], v[9], v[14] = mix(v[3], v[4], v[9], v[14], m[s[14]], m[s[15]], mka: mka)
          end

          def state_2b=(state)
            @h = state
          end

          def transform_2b(block)
            transform(block)
          end

          def output_2b
            @h.pack('Q<8')[0..(@output_length - 1)]
          end
        end
      end
    end
  end
end

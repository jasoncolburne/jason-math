# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      class Digest
        # rubocop:disable Naming/VariableNumber
        # SHA
        class SecureHashAlgorithm # rubocop:disable Metrics/ClassLength
          attr_accessor :cumulative_length

          K = {
            64 => [
              0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
              0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
              0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
              0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
              0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
              0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
              0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
              0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
            ].freeze,
            128 => [
              0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538,
              0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe,
              0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235,
              0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
              0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab,
              0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725,
              0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed,
              0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
              0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218,
              0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53,
              0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373,
              0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
              0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c,
              0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6,
              0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc,
              0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817
            ].freeze
          }.freeze

          O = {
            64 => [7, 18, 3, 17, 19, 10, 2, 13, 22, 6, 11, 25].freeze,
            128 => [1, 8, 7, 19, 61, 6, 28, 34, 39, 14, 18, 41].freeze
          }.freeze

          RC = [
            0x0000000000000001, 0x0000000000008082, 0x800000000000808a,
            0x8000000080008000, 0x000000000000808b, 0x0000000080000001,
            0x8000000080008081, 0x8000000000008009, 0x000000000000008a,
            0x0000000000000088, 0x0000000080008009, 0x000000008000000a,
            0x000000008000808b, 0x800000000000008b, 0x8000000000008089,
            0x8000000000008003, 0x8000000000008002, 0x8000000000000080,
            0x000000000000800a, 0x800000008000000a, 0x8000000080008081,
            0x8000000000008080, 0x0000000080000001, 0x8000000080008008
          ].freeze

          R = [
            [0, 36, 3, 41, 18].freeze,
            [1, 44, 10, 45, 2].freeze,
            [62, 6, 43, 15, 61].freeze,
            [28, 55, 25, 21, 56].freeze,
            [27, 20, 39, 8, 14].freeze
          ].freeze

          KECCAK_ALGORITHMS = %i[shake128 shake256 3_224 3_256 3_384 3_512].freeze

          PARAMETERS = {
            '1': { # 80 bits of security
              h: [
                0x67452301,
                0xefcdab89,
                0x98badcfe,
                0x10325476,
                0xc3d2e1f0
              ].freeze,
              max_integer: 2**32,
              block_size: 64
            }.freeze,
            '224': { # 112 bits of security
              h: [
                0xc1059ed8,
                0x367cd507,
                0x3070dd17,
                0xf70e5939,
                0xffc00b31,
                0x68581511,
                0x64f98fa7,
                0xbefa4fa4
              ].freeze,
              rounds: 64,
              max_integer: 2**32,
              block_size: 64
            }.freeze,
            '256': { # 128 bits of security
              h: [
                0x6a09e667,
                0xbb67ae85,
                0x3c6ef372,
                0xa54ff53a,
                0x510e527f,
                0x9b05688c,
                0x1f83d9ab,
                0x5be0cd19
              ].freeze,
              rounds: 64,
              max_integer: 2**32,
              block_size: 64
            }.freeze,
            '384': { # 192 bits of security
              h: [
                0xcbbb9d5dc1059ed8,
                0x629a292a367cd507,
                0x9159015a3070dd17,
                0x152fecd8f70e5939,
                0x67332667ffc00b31,
                0x8eb44a8768581511,
                0xdb0c2e0d64f98fa7,
                0x47b5481dbefa4fa4
              ].freeze,
              rounds: 80,
              max_integer: 2**64,
              block_size: 128
            }.freeze,
            '512': { # 256 bits of security
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
              rounds: 80,
              max_integer: 2**64,
              block_size: 128
            }.freeze,
            '512_224': { # 112 bits of security
              h: [
                0x8c3d37c819544da2,
                0x73e1996689dcd4d6,
                0x1dfab7ae32ff9c82,
                0x679dd514582f9fcf,
                0x0f6d2b697bd44da8,
                0x77e36f7304c48942,
                0x3f9d85a86a1d36c8,
                0x1112e6ad91d692a1
              ].freeze,
              rounds: 80,
              max_integer: 2**64,
              block_size: 128
            }.freeze,
            '512_256': { # 128 bits of security
              h: [
                0x22312194fc2bf72c,
                0x9f555fa3c84c64c2,
                0x2393b86b6f53b151,
                0x963877195940eabd,
                0x96283ee2a88effe3,
                0xbe5e1e2553863992,
                0x2b0199fc2c85b8aa,
                0x0eb72ddc81c52ca2
              ].freeze,
              rounds: 80,
              max_integer: 2**64,
              block_size: 128
            }.freeze,
            'shake128': {
              r: 1344,
              c: 256,
              d: 0x1f,
              mask: 0xffffffffffffffff,
              block_size: 168
            },
            'shake256': {
              r: 1088,
              c: 512,
              d: 0x1f,
              mask: 0xffffffffffffffff,
              block_size: 136
            },
            '3_224': { # 112 bits of security
              r: 1152,
              c: 448,
              d: 0x06,
              mask: 0xffffffffffffffff,
              block_size: 144
            },
            '3_256': { # 128 bits of security
              r: 1088,
              c: 512,
              d: 0x06,
              mask: 0xffffffffffffffff,
              block_size: 136
            },
            '3_384': { # 192 bits of security
              r: 832,
              c: 768,
              d: 0x06,
              mask: 0xffffffffffffffff,
              block_size: 104
            },
            '3_512': { # 256 bits of security
              r: 576,
              c: 1024,
              d: 0x06,
              mask: 0xffffffffffffffff,
              block_size: 72
            }
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
            blocks.each { |block| send("transform_#{@algorithm}", block) }

            nil
          end

          alias << update

          def finish
            to_transform = if KECCAK_ALGORITHMS.include?(@algorithm)
                             keccak_pad(@to_transform)
                           else
                             Digest.pad(@to_transform, :network, @cumulative_length, @block_size)
                           end

            blocks = Cipher.split_into_blocks(to_transform, @block_size)
            blocks.each { |block| send("transform_#{@algorithm}", block) }

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

          private

          def reset
            @cumulative_length = 0
            @to_transform = ''.b

            parameters = PARAMETERS[@algorithm]
            parameters.each_pair { |key, value| instance_variable_set("@#{key}", value) unless key == :h }

            if KECCAK_ALGORITHMS.include?(@algorithm)
              @a = []
              5.times { @a << [0, 0, 0, 0, 0] }
            else
              @h = parameters[:h].dup
            end
          end

          def state_1=(state)
            @h = state
          end

          def output_1
            @h.pack('N5')
          end

          def transform_1(block) # rubocop:disable Metrics/MethodLength
            h = @h.dup
            w = block.unpack('N*')

            (16..79).each do |i|
              w << Utility.rotate_left(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1)
            end

            (0..79).each do |i|
              f, k = case i
                     when 0..19
                       f = (h[1] & h[2]) | ((~h[1] % @max_integer) & h[3])
                       [f, 0x5a827999]
                     when 20..39
                       f = h[1] ^ h[2] ^ h[3]
                       [f, 0x6ed9eba1]
                     when 40..59
                       f = (h[1] & h[2]) | (h[1] & h[3]) | (h[2] & h[3])
                       [f, 0x8f1bbcdc]
                     when 60..79
                       f = h[1] ^ h[2] ^ h[3]
                       [f, 0xca62c1d6]
                     end

              temp = (Utility.rotate_left(h[0], 5) + f + h[4] + k + w[i]) % @max_integer
              h[4] = h[3]
              h[3] = h[2]
              h[2] = Utility.rotate_left(h[1], 30)
              h[1] = h[0]
              h[0] = temp
            end

            5.times do |i|
              @h[i] = (@h[i] + h[i]) % @max_integer
            end
          end

          def state_2=(state)
            @h = state
          end

          alias state_224= state_2=
          alias state_256= state_2=
          alias state_384= state_2=
          alias state_512= state_2=
          alias state_512_224= state_2=
          alias state_512_256= state_2=

          def transform_2(block) # rubocop:disable Metrics/MethodLength
            h = @h.dup

            o = O[@block_size]
            k = K[@block_size]

            unpacking_param = @max_integer == 4_294_967_296 ? 'N16' : 'Q>16'
            w = block.unpack(unpacking_param)
            mask = @max_integer - 1

            (16..(@rounds - 1)).each do |i|
              s0 = w[i - 15]
              s0 = Utility.rotate_right(s0, o[0], mask) ^ Utility.rotate_right(s0, o[1], mask) ^ (s0 >> o[2])
              s1 = w[i - 2]
              s1 = Utility.rotate_right(s1, o[3], mask) ^ Utility.rotate_right(s1, o[4], mask) ^ (s1 >> o[5])

              w << (w[i - 16] + s0 + w[i - 7] + s1) % @max_integer
            end

            (0..(@rounds - 1)).each do |i|
              s1 = Utility.rotate_right(h[4], o[9], mask) ^ \
                   Utility.rotate_right(h[4], o[10], mask) ^ \
                   Utility.rotate_right(h[4], o[11], mask)
              ch = (h[4] & h[5]) ^ ((~h[4] % @max_integer) & h[6])
              temp1 = h[7] + s1 + ch + k[i] + w[i] # modular arithmetic handled in computation below
              s0 = Utility.rotate_right(h[0], o[6], mask) ^ \
                   Utility.rotate_right(h[0], o[7], mask) ^ \
                   Utility.rotate_right(h[0], o[8], mask)
              maj = (h[0] & h[1]) ^ (h[0] & h[2]) ^ (h[1] & h[2])
              temp2 = s0 + maj # modular arithmetic handled in computation below

              h[7] = h[6]
              h[6] = h[5]
              h[5] = h[4]
              h[4] = (h[3] + temp1) % @max_integer
              h[3] = h[2]
              h[2] = h[1]
              h[1] = h[0]
              h[0] = (temp1 + temp2) % @max_integer
            end

            8.times do |i|
              @h[i] = (@h[i] + h[i]) % @max_integer
            end
          end

          alias transform_224 transform_2
          alias transform_256 transform_2
          alias transform_384 transform_2
          alias transform_512 transform_2
          alias transform_512_224 transform_2
          alias transform_512_256 transform_2

          def output_224
            @h.pack('N7')
          end

          def output_256
            @h.pack('N8')
          end

          def output_384
            @h.pack('Q>6')
          end

          def output_512
            @h.pack('Q>8')
          end

          def output_512_224
            @h.pack('Q>3') + [@h[3] >> 32].pack('N1')
          end

          def output_512_256
            @h.pack('Q>4')
          end

          def keccak_pad(data)
            data += @d.chr
            bytes_to_add = @block_size - (data.length % @block_size)
            bytes_to_add = @block_size if bytes_to_add.zero?
            data += "\x00" * bytes_to_add
            data[-1] = Utility.xor(data[-1], "\x80")
            data
          end

          def keccak_f1600(block)
            words = block.unpack('Q<*')

            word_count = @block_size / 8
            done = false
            5.times do |y|
              5.times do |x|
                done = true if y * 5 + x == word_count
                break if done

                @a[x][y] ^= words[x + 5 * y]
              end
              break if done
            end

            24.times do |x|
              keccak_round(RC[x])
            end
          end

          alias transform_shake128 keccak_f1600
          alias transform_shake256 keccak_f1600
          alias transform_3_224 keccak_f1600
          alias transform_3_256 keccak_f1600
          alias transform_3_384 keccak_f1600
          alias transform_3_512 keccak_f1600

          def keccak_round(rc) # rubocop:disable Metrics/MethodLength
            b = []
            c = []
            d = []

            # θ step
            5.times do |x|
              c << @a[x].inject(&:^)
            end

            5.times do |x|
              d << (c[(x - 1) % 5] ^ Utility.rotate_left(c[(x + 1) % 5], 1, @mask))
            end

            5.times do |x|
              5.times do |y|
                @a[x][y] ^= d[x]
              end
            end

            # ρ and π steps
            5.times do |x|
              5.times do |y|
                b[y] ||= []
                b[y][(2 * x + 3 * y) % 5] = Utility.rotate_left(@a[x][y], R[x][y], @mask)
              end
            end

            # χ step
            5.times do |x|
              5.times do |y|
                @a[x][y] = b[x][y] ^ ((~b[(x + 1) % 5][y]) & b[(x + 2) % 5][y])
              end
            end

            # ι step
            @a[0][0] ^= rc
          end

          def output_keccak(output_length)
            z = ''.b

            loop do
              length = [@block_size, output_length].min
              to_pack = []
              5.times do |y|
                5.times do |x|
                  to_pack << @a[x][y]
                end
              end
              z += to_pack.pack('Q<25')[0..(length - 1)] # @a.flatten.pack('Q>25')[0..(length - 1)]
              output_length -= length
              break if output_length.zero?

              keccak_f1600("\x00" * @block_size)
            end

            z
          end

          def output_shake128
            output_keccak(32)
          end

          def output_shake256
            output_keccak(64)
          end

          def output_3_224
            output_keccak(28)
          end

          def output_3_256
            output_keccak(32)
          end

          def output_3_384
            output_keccak(48)
          end

          def output_3_512
            output_keccak(64)
          end
        end
        # rubocop:enable Naming/VariableNumber
      end
    end
  end
end

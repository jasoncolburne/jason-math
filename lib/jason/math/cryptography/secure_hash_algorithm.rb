# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
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

        PARAMETERS = {
          '1': {
            h0: 0x67452301,
            h1: 0xefcdab89,
            h2: 0x98badcfe,
            h3: 0x10325476,
            h4: 0xc3d2e1f0,
            max_integer: 2**32,
            block_size: 64
          }.freeze,
          '224': {
            h0: 0xc1059ed8,
            h1: 0x367cd507,
            h2: 0x3070dd17,
            h3: 0xf70e5939,
            h4: 0xffc00b31,
            h5: 0x68581511,
            h6: 0x64f98fa7,
            h7: 0xbefa4fa4,
            rounds: 64,
            max_integer: 2**32,
            block_size: 64
          }.freeze,
          '256': {
            h0: 0x6a09e667,
            h1: 0xbb67ae85,
            h2: 0x3c6ef372,
            h3: 0xa54ff53a,
            h4: 0x510e527f,
            h5: 0x9b05688c,
            h6: 0x1f83d9ab,
            h7: 0x5be0cd19,
            rounds: 64,
            max_integer: 2**32,
            block_size: 64
          }.freeze,
          '384': {
            h0: 0xcbbb9d5dc1059ed8,
            h1: 0x629a292a367cd507,
            h2: 0x9159015a3070dd17,
            h3: 0x152fecd8f70e5939,
            h4: 0x67332667ffc00b31,
            h5: 0x8eb44a8768581511,
            h6: 0xdb0c2e0d64f98fa7,
            h7: 0x47b5481dbefa4fa4,
            rounds: 80,
            max_integer: 2**64,
            block_size: 128
          }.freeze,
          '512': {
            h0: 0x6a09e667f3bcc908,
            h1: 0xbb67ae8584caa73b,
            h2: 0x3c6ef372fe94f82b,
            h3: 0xa54ff53a5f1d36f1,
            h4: 0x510e527fade682d1,
            h5: 0x9b05688c2b3e6c1f,
            h6: 0x1f83d9abfb41bd6b,
            h7: 0x5be0cd19137e2179,
            rounds: 80,
            max_integer: 2**64,
            block_size: 128
          }.freeze,
          '512_224': {
            h0: 0x8c3d37c819544da2,
            h1: 0x73e1996689dcd4d6,
            h2: 0x1dfab7ae32ff9c82,
            h3: 0x679dd514582f9fcf,
            h4: 0x0f6d2b697bd44da8,
            h5: 0x77e36f7304c48942,
            h6: 0x3f9d85a86a1d36c8,
            h7: 0x1112e6ad91d692a1,
            rounds: 80,
            max_integer: 2**64,
            block_size: 128
          }.freeze,
          '512_256': {
            h0: 0x22312194fc2bf72c,
            h1: 0x9f555fa3c84c64c2,
            h2: 0x2393b86b6f53b151,
            h3: 0x963877195940eabd,
            h4: 0x96283ee2a88effe3,
            h5: 0xbe5e1e2553863992,
            h6: 0x2b0199fc2c85b8aa,
            h7: 0x0eb72ddc81c52ca2,
            rounds: 80,
            max_integer: 2**64,
            block_size: 128
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
          blocks.each { |block| send("transform_#{@algorithm}", block) }

          nil
        end

        alias << update

        def finish
          to_transform = Digest.pad(@to_transform, :network, @cumulative_length, @block_size)
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
          parameters.each_pair { |key, value| instance_variable_set("@#{key}", value) }
        end

        def state_1=(state)
          @h0, @h1, @h2, @h3, @h4 = state
        end

        def output_1
          [@h0, @h1, @h2, @h3, @h4].pack('N5')
        end

        def transform_1(block) # rubocop:disable Metrics/MethodLength
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
                     f = (b & c) | ((~b % @max_integer) & d)
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

        def state_2=(state)
          @h0, @h1, @h2, @h3, @h4, @h5, @h6, @h7 = state
        end

        def transform_2(block) # rubocop:disable Metrics/MethodLength
          a = @h0
          b = @h1
          c = @h2
          d = @h3
          e = @h4
          f = @h5
          g = @h6
          h = @h7

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
            s1 = Utility.rotate_right(e, o[9], mask) ^ \
                 Utility.rotate_right(e, o[10], mask) ^ \
                 Utility.rotate_right(e, o[11], mask)
            ch = (e & f) ^ ((~e % @max_integer) & g)
            temp1 = h + s1 + ch + k[i] + w[i] # modular arithmetic handled in computation below
            s0 = Utility.rotate_right(a, o[6], mask) ^ \
                 Utility.rotate_right(a, o[7], mask) ^ \
                 Utility.rotate_right(a, o[8], mask)
            maj = (a & b) ^ (a & c) ^ (b & c)
            temp2 = s0 + maj # modular arithmetic handled in computation below

            h = g
            g = f
            f = e
            e = (d + temp1) % @max_integer
            d = c
            c = b
            b = a
            a = (temp1 + temp2) % @max_integer
          end

          @h0 = (@h0 + a) % @max_integer
          @h1 = (@h1 + b) % @max_integer
          @h2 = (@h2 + c) % @max_integer
          @h3 = (@h3 + d) % @max_integer
          @h4 = (@h4 + e) % @max_integer
          @h5 = (@h5 + f) % @max_integer
          @h6 = (@h6 + g) % @max_integer
          @h7 = (@h7 + h) % @max_integer
        end

        def state_224=(state)
          self.state_2 = state
        end

        def transform_224(block)
          transform_2(block)
        end

        def output_224
          [@h0, @h1, @h2, @h3, @h4, @h5, @h6].pack('N7')
        end

        def state_256=(state)
          self.state_2 = state
        end

        def transform_256(block)
          transform_2(block)
        end

        def output_256
          [@h0, @h1, @h2, @h3, @h4, @h5, @h6, @h7].pack('N8')
        end

        def state_384=(state)
          self.state_2 = state
        end

        def transform_384(block)
          transform_2(block)
        end

        def output_384
          [@h0, @h1, @h2, @h3, @h4, @h5].pack('Q>6')
        end

        def state_512=(state)
          self.state_2 = state
        end

        def transform_512(block)
          transform_2(block)
        end

        def output_512
          [@h0, @h1, @h2, @h3, @h4, @h5, @h6, @h7].pack('Q>8')
        end

        def state_512_224=(state)
          self.state_2 = state
        end

        def transform_512_224(block)
          transform_2(block)
        end

        def output_512_224
          [@h0, @h1, @h2].pack('Q>3') + [@h3 >> 32].pack('N1')
        end

        def state_512_256=(state)
          self.state_2 = state
        end

        def transform_512_256(block)
          transform_2(block)
        end

        def output_512_256
          [@h0, @h1, @h2, @h3].pack('Q>4')
        end
      end
      # rubocop:enable Naming/VariableNumber
    end
  end
end

# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      module KeyEncapsulation
        # The Streamlined NTRU Prime suite
        class StreamlinedNTRUPrime
          # Rings used by Streamlined NTRU Prime
          module Ring
            # The Quotient ring over x^p - x - 1
            class NTRUQuotient
              attr_reader :field

              def initialize(field)
                @field = field
              end

              def multiply(f, g)
                raise 'input polynomials differ in length' unless f.length == g.length

                p = f.length

                fg = [0] * (p + p - 1)

                p.times do |i|
                  result = 0
                  (i + 1).times { |j| result = @field.to_zz(result + f[j] * g[i - j]) }
                  fg[i] = result
                end

                p.upto(p + p - 2) do |i|
                  result = 0
                  (i - p + 1).upto(p - 1) { |j| result = @field.to_zz(result + f[j] * g[i - j]) }
                  fg[i] = result
                end

                (p + p - 2).downto(p) do |i|
                  fg[i - p] = @field.to_zz(fg[i - p] + fg[i])
                  fg[i - p + 1] = @field.to_zz(fg[i - p + 1] + fg[i])
                end

                fg[0..(p - 1)]
              end

              def scale(f, k)
                f.map { |a| @field.to_zz(a * k) }
              end

              # 1/e in R/3
              def reciprocal(e) # rubocop:disable Metrics/MethodLength
                p = e.length
                f = [0] * (p + 1)
                g = e.reverse
                v = [0] * (p + 1)
                r = [0] * (p + 1)

                r[0] = 1

                # this is the x^p - x - 1
                f[0] = 1
                f[p - 1] = -1
                f[p] = -1

                g << 0

                delta = 1
                (2 * p - 1).times do |_loop|
                  v.pop
                  v.unshift(0)

                  sign = -g[0] * f[0]
                  swap = delta.positive? && !g[0].zero? ? -1 : 0
                  delta ^= (swap & (delta ^ (-delta)))
                  delta += 1

                  (p + 1).times do |i|
                    t = swap & (f[i] ^ g[i])
                    f[i] ^= t
                    g[i] ^= t

                    t = swap & (v[i] ^ r[i])
                    v[i] ^= t
                    r[i] ^= t
                  end

                  (p + 1).times { |i| g[i] = @field.to_zz(g[i] + sign * f[i]) }
                  (p + 1).times { |i| r[i] = @field.to_zz(r[i] + sign * v[i]) }

                  g.shift
                  g << 0
                end

                sign = f[0]
                result = v.reverse[1..].map { |a| sign * a }

                delta.zero? ? result : nil
              end

              # 1/3e in R/q
              def reciprocal_3(e) # rubocop:disable Metrics/MethodLength,Naming/VariableNumber
                p = e.length
                f = [0] * (p + 1)
                g = e.reverse
                v = [0] * (p + 1)
                r = [0] * (p + 1)

                r[0] = @field.reciprocal(3)

                # again, here's the irreducible polynomial
                f[0] = 1
                f[p - 1] = -1
                f[p] = -1

                g << 0

                delta = 1

                (2 * p - 1).times do |_loop|
                  v.pop
                  v.unshift(0)

                  swap = delta.positive? && !g[0].zero? ? -1 : 0
                  delta ^= swap & (delta ^ (-delta))
                  delta += 1

                  (p + 1).times do |i|
                    t = swap & (f[i] ^ g[i])
                    f[i] ^= t
                    g[i] ^= t

                    t = swap & (v[i] ^ r[i])
                    v[i] ^= t
                    r[i] ^= t
                  end

                  f0 = f[0]
                  g0 = g[0]
                  (p + 1).times { |i| g[i] = @field.to_zz(f0 * g[i] - g0 * f[i]) }
                  (p + 1).times { |i| r[i] = @field.to_zz(f0 * r[i] - g0 * v[i]) }

                  g.shift
                  g << 0
                end

                scale = @field.reciprocal(f[0])
                result = v.reverse[1..].map { |a| @field.to_zz(scale * a) }

                delta.zero? ? result : nil
              end
            end
          end

          # Just the basics
          class PrimeGaloisField
            attr_accessor :q, :q12

            def initialize(q)
              raise 'q must be prime' unless NumberTheory.prime?(q)

              @q = q
              @q12 = (q - 1) / 2
            end

            def to_zz(e)
              (e + @q12) % @q - @q12
            end

            def reciprocal(e)
              ai = e
              (q - 3).times { ai = to_zz(e * ai) }
              ai
            end
          end

          def generate_keypair
            pk, sk = z_keygen
            sk += pk
            @rho = SecureRandom.random_bytes(@small_bytes)
            sk += @rho
            @cache = hash_prefix(4, pk)
            sk += @cache

            [pk, sk]
          end

          def encapsulate
            raise 'cannot encapsulate without public key' if @public_key.nil?

            r = random_short
            c, r_enc = hide(r)
            [c, hash_session(1, r_enc, c)]
          end

          def decapsulate(cipher_text)
            raise 'cannot decapsulate without keypair' if @public_key.nil? || @private_key.nil?

            c_original = cipher_text
            c_inner = cipher_text[0..-33]

            r = z_decrypt(c_inner)
            c_new, r_enc = hide(r, @cache)

            c_new == c_original ? hash_session(1, r_enc, c_original) : hash_session(0, @rho, c_original)
          end

          private

          def hide(r, cache = nil)
            r_enc = small_encode(r)
            c = z_encrypt(r)
            c += hash_confirm(r_enc, rq_encode(@public_key), cache)
            [c, r_enc]
          end

          # Core
          module Core # rubocop:disable Metrics/ModuleLength
            attr_reader :private_key, :public_key

            PARAMETERS = {
              sntrup653: {
                p: 653,
                q: 4621,
                w: 288
              }.freeze,
              sntrup761: {
                p: 761,
                q: 4591,
                w: 286
              }.freeze,
              sntrup857: {
                p: 857,
                q: 5167,
                w: 322
              }.freeze,
              sntrup953: {
                p: 953,
                q: 6343,
                w: 396
              }.freeze,
              sntrup1013: {
                p: 1013,
                q: 7177,
                w: 448
              }.freeze,
              sntrup1277: {
                p: 1277,
                q: 7879,
                w: 492
              }.freeze
            }.freeze

            def initialize(parameter_set, private_key = nil, public_key = nil)
              PARAMETERS[parameter_set].each do |key, value|
                instance_variable_set("@#{key}", value)
              end

              @sha512 = Digest::SecureHashAlgorithm.new(:'512')

              @f3 = PrimeGaloisField.new(3)
              @fq = PrimeGaloisField.new(@q)
              @r3 = Ring::NTRUQuotient.new(@f3)
              @rq = Ring::NTRUQuotient.new(@fq)

              @small_bytes = (@p + 3) / 4

              self.private_key = private_key unless private_key.nil?
              self.public_key = public_key unless public_key.nil?
            end

            def public_key=(s)
              @public_key = rq_decode(s)
            end

            def private_key=(s)
              @private_key = [small_decode(s[0..(@small_bytes - 1)]),
                              small_decode(s[@small_bytes..(2 * @small_bytes - 1)])]
              @public_key = rq_decode(s[(2 * @small_bytes)..-(33 + @small_bytes)])
              @rho = s[-(32 + @small_bytes)..-33]
              @cache = s[-32..]
            end

            private

            def random_range_3 # rubocop:disable Naming/VariableNumber
              (SecureRandom.random_number(0x3fffffff) * 3) >> 30
            end

            def random_small
              @p.times.map { random_range_3 - 1 }
            end

            def random_short
              short_from_list(@p.times.map { SecureRandom.random_number(0xffffffff) })
            end

            def short_from_list(l)
              l = l[0..(@w - 1)].map { |a| a & (-2) } + l[@w..].map { |a| (a & (-3)) | 1 }
              l.sort!
              l.map { |a| (a & 3) - 1 }
            end

            def round(g)
              g.map { |a| a - @f3.to_zz(a) }
            end

            def weight(r)
              r.map { |a| a.zero? ? 0 : 1 }.sum
            end

            def keygen
              # generate uniform random, invertible element g in R
              v = nil
              g = nil

              while v.nil?
                g = random_small
                # compute 1/g in R/3
                v = @r3.reciprocal(g)
              end

              # generate uniform random f in Short
              f = random_short

              # compute h = g/(3f) in R/q
              h = @rq.multiply(g, @rq.reciprocal_3(f))

              @private_key = [f, v].freeze
              @public_key = h
              [@public_key, @private_key].freeze
            end

            def encrypt(clear_text)
              round(@rq.multiply(@public_key, clear_text))
            end

            def decrypt(cipher_text)
              c = cipher_text
              f, v = @private_key
              g = @rq.scale(@rq.multiply(c, f), 3) # g = 3cf in R/q
              e = g.map { |a| @f3.to_zz(a) }
              r = @r3.multiply(e, v)

              default_r = @default_decryption_result.dup
              weight(r) == @w ? r : default_r
            end
          end
          include Core

          # Glue layer
          module Glue
            private

            def z_keygen
              public_key, private_key = keygen
              f, v = private_key

              [rq_encode(public_key), small_encode(f) + small_encode(v)]
            end

            def z_encrypt(r)
              rounded_encode(encrypt(r))
            end

            def z_decrypt(c)
              decrypt(rounded_decode(c))
            end
          end
          include Glue

          # Encoding
          module Encoding # rubocop:disable Metrics/ModuleLength
            private

            def small_encode(f)
              (((@p / 4).times.map do |i|
                x = f[i * 4] + 1
                x += ((f[i * 4 + 1] + 1) << 2)
                x += ((f[i * 4 + 2] + 1) << 4)
                x += ((f[i * 4 + 3] + 1) << 6)

                x
              end) + [f[-1] + 1]).pack('C*')
            end

            def small_decode(s)
              f = []

              (@p / 4).times.map do |i|
                x = s[i].ord

                f << (x & 3) - 1
                x >>= 2
                f << (x & 3) - 1
                x >>= 2
                f << (x & 3) - 1
                x >>= 2
                f << (x & 3) - 1
              end

              f + [(s[-1].ord & 3) - 1]
            end

            # rubocop:disable Lint/UnderscorePrefixedVariableName
            def encode(r, m) # rubocop:disable Metrics/MethodLength
              return [] if m.length.zero?

              s = []
              if m.length == 1
                _r = r[0]
                _m = m[0]

                while _m > 1
                  s << (_r % 256)
                  _r /= 256
                  _m = (_m + 255) / 256
                end
                return s
              end

              r2 = []
              m2 = []
              (0..(m.length - 2)).step(2) do |i|
                _m = m[i] * m[i + 1]
                _r = r[i] + m[i] * r[i + 1]

                while _m >= 16_384
                  s << (_r % 256)
                  _r /= 256
                  _m = (_m + 255) / 256
                end

                r2 << _r
                m2 << _m
              end

              if m.length.odd?
                r2 << r[-1]
                m2 << m[-1]
              end

              s + encode(r2, m2)
            end

            def decode(s, m) # rubocop:disable Metrics/MethodLength
              return [] if m.length.zero?

              return [s.length.times.map { |i| s[i] * (256**i) }.sum % m[0]] if m.length == 1

              k = 0
              bottom = []
              m2 = []
              (0..(m.length - 2)).step(2) do |i|
                _m = m[i] * m[i + 1]
                r = 0
                t = 1

                while _m >= 16_384
                  r += s[k] * t
                  t *= 256
                  k += 1
                  _m = (_m + 255) / 256
                end

                bottom << [r, t]
                m2 << _m
              end

              m2 << m[-1] if m.length.odd?
              r2 = decode(s[k..], m2)
              r = []

              (0..(m.length - 2)).step(2) do |i|
                _r, t = bottom[i / 2]
                _r += t * r2[i / 2]
                r << (_r % m[i])
                r << ((_r / m[i]) % m[i + 1])
              end

              r << r2[-1] if m.length.odd?
              r
            end
            # rubocop:enable Lint/UnderscorePrefixedVariableName

            def rq_encode(r)
              r = r.map { |a| @fq.to_zz(a) + @fq.q12 }
              m = [@q] * @p
              encode(r, m).pack('C*')
            end

            def rq_decode(s)
              m = [@q] * @p
              r = decode(s.unpack('C*'), m)
              r.map { |a| a - @fq.q12 }
            end

            def rounded_encode(r)
              r = r.map { |a| (@fq.to_zz(a) + @fq.q12) / 3 }
              m = [(@q + 2) / 3 + 1] * @p
              encode(r, m).pack('C*')
            end

            def rounded_decode(s)
              m = [(@q + 2) / 3 + 1] * @p
              r = decode(s.unpack('C*'), m)
              r.map { |a| a * 3 - @fq.q12 }
            end
          end
          include Encoding

          # Hashing
          module Hashing
            private

            def hash(message)
              @sha512.digest(message)[0..31]
            end

            def hash_prefix(n, message)
              hash(n.chr + message)
            end

            def hash_confirm(r, k, cache = nil)
              cache = hash_prefix(4, k) if cache.nil?
              r = hash_prefix(3, r)
              hash_prefix(2, r + cache)
            end

            def hash_session(b, y, z)
              y = hash_prefix(3, y)
              hash_prefix(b, y + z)
            end
          end
          include Hashing
        end
      end
    end
  end
end

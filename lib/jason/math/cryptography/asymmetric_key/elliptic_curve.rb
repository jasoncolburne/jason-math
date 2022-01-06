# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      module AsymmetricKey
        # ECC
        class EllipticCurve
          # originally, a port of https://gist.github.com/bellbind/1414867/04ccbaa3fe97304d3d9d91c36520a662f2e28a45

          # A point on an elliptic curve
          class Point
            attr_reader :x, :y

            def initialize(x, y)
              @x = x
              @y = y
            end

            def +(other)
              Point.new(@x + other.x, @y + other.y)
            end

            def ==(other)
              @x == other.x && @y == other.y
            end

            def to_s
              "[#{@x}, #{@y}]"
            end

            def to_a
              [@x, @y]
            end

            def to_hex(width)
              @x.to_s(16).rjust(width, '0') + @y.to_s(16).rjust(width, '0')
            end

            def to_byte_string(width)
              Utility.integer_to_byte_string(@x).rjust(width, "\x00") +
                Utility.integer_to_byte_string(@y).rjust(width, "\x00")
            end

            def self.from_hex(hex_string)
              width = hex_string.length / 2
              new(hex_string[0..(width - 1)].to_i(16), hex_string[width..(2 * width - 1)].to_i(16))
            end

            def self.from_byte_string(byte_string)
              width = byte_string.length / 2
              new(
                Utility.byte_string_to_integer(byte_string[0..(width - 1)]),
                Utility.byte_string_to_integer(byte_string[width..(2 * width - 1)])
              )
            end
          end

          # An elliptic curve
          class Curve
            attr_reader :a, :b, :p, :zero

            # (y**2 = x**3 + a * x + b) mod n
            def initialize(a, b, p)
              @a = a
              @b = b
              @p = p

              @zero = Point.new(0, 0)
            end

            def valid?(p)
              return true if p == @zero

              l = (p.y * p.y) % @p
              r = ((p.x * p.x * p.x) + @a * p.x + @b) % @p

              l == r
            end

            def negate(p)
              Point.new(p.x, -p.y % @p)
            end

            def add(p1, p2)
              return p2 if p1 == @zero
              return p1 if p2 == @zero

              # p1 + -p1 == 0
              return @zero if p1.x == p2.x && (p1.y != p2.y || p1.y.zero?)

              l = if p1.x == p2.x
                    (3 * p1.x * p1.x + @a) * NumberTheory.modular_inverse(2 * p1.y, @p) % @p
                  else
                    (p2.y - p1.y) * NumberTheory.modular_inverse(p2.x - p1.x, @p) % @p
                  end

              x = (l * l - p1.x - p2.x) % @p
              y = (l * (p1.x - x) - p1.y) % @p

              Point.new(x, y)
            end

            def multiply(p, n)
              r = @zero
              m2 = p

              # O(log2(n)) add
              while n.positive?
                r = add(r, m2) if n & 1 == 1
                n = n >> 1
                m2 = add(m2, m2)
              end

              r
            end

            def order(p)
              raise 'Invalid order' unless valid?(p) && (p != @zero)

              (1..(@p + 1)).each do |i|
                return i if multiply(p, i) == @zero
              end

              raise 'Invalid order'
            end
          end

          # include Math

          PARAMETERS = {
            secp112r1: {
              p: 'db7c2abf62e35e668076bead208b',
              a: 'db7c2abf62e35e668076bead2088',
              b: '659ef8ba043916eede8911702b22',
              generator: %w[
                09487239995a5ee76b55f9c2f098
                a89ce5af8724c0a23e0e0ff77500
              ].freeze,
              n: 'db7c2abf62e35e7628dfac6561c5'
            },
            secp112r2: {
              p: 'db7c2abf62e35e668076bead208b',
              a: '6127c24c05f38a0aaaf65c0ef02c',
              b: '51def1815db5ed74fcc34c85d709',
              generator: %w[
                4ba30ab5e892b4e1649dd0928643
                adcd46f5882e3747def36e956e97
              ].freeze,
              n: '36df0aafd8b8d7597ca10520d04b'
            },
            secp128r1: {
              p: 'fffffffdffffffffffffffffffffffff',
              a: 'fffffffdfffffffffffffffffffffffc',
              b: 'e87579c11079f43dd824993c2cee5ed3',
              generator: %w[
                161ff7528b899b2d0c28607ca52c5b86
                cf5ac8395bafeb13c02da292dded7a83
              ].freeze,
              n: 'fffffffe0000000075a30d1b9038a115'
            },
            secp128r2: {
              p: 'fffffffdffffffffffffffffffffffff',
              a: 'd6031998d1b3bbfebf59cc9bbff9aee1',
              b: '5eeefca380d02919dc2c6558bb6d8a5d',
              generator: %w[
                7b6aa5d85e572983e6fb32a7cdebc140
                27b6916a894d3aee7106fe805fc34b44
              ].freeze,
              n: '3fffffff7fffffffbe0024720613b5a3'
            },
            secp160k1: { # 80 bits of security
              p: 'fffffffffffffffffffffffffffffffeffffac73',
              a: '0000000000000000000000000000000000000000',
              b: '0000000000000000000000000000000000000007',
              generator: %w[
                3b4c382ce37aa192a4019e763036f4f5dd4d7ebb
                938cf935318fdced6bc28286531733c3f03c4fee
              ].freeze,
              n: '0100000000000000000001b8fa16dfab9aca16b6b3'
            },
            secp160r1: { # 80 bits of security
              p: 'ffffffffffffffffffffffffffffffff7fffffff',
              a: 'ffffffffffffffffffffffffffffffff7ffffffc',
              b: '1c97befc54bd7a8b65acf89f81d4d4adc565fa45',
              generator: %w[
                4a96b5688ef573284664698968c38bb913cbfc82
                23a628553168947d59dcc912042351377ac5fb32
              ].freeze,
              n: '0100000000000000000001f4c8f927aed3ca752257'
            },
            secp160r2: { # 80 bits of security
              p: 'fffffffffffffffffffffffffffffffeffffac73',
              a: 'fffffffffffffffffffffffffffffffeffffac70',
              b: 'b4e134d3fb59eb8bab57274904664d5af50388ba',
              generator: %w[
                52dcb034293a117e1f4ff11b30f7199d3144ce6d
                feaffef2e331f296e071fa0df9982cfea7d43f2e
              ].freeze,
              n: '0100000000000000000000351ee786a818f3a1a16b'
            },
            secp192k1: {
              p: 'fffffffffffffffffffffffffffffffffffffffeffffee37',
              a: '000000000000000000000000000000000000000000000000',
              b: '000000000000000000000000000000000000000000000003',
              generator: %w[
                db4ff10ec057e9ae26b07d0280b7f4341da5d1b1eae06c7d
                9b2f2f6d9c5628a7844163d015be86344082aa88d95e2f9d
              ].freeze,
              n: 'fffffffffffffffffffffffe26f2fc170f69466a74defd8d'
            },
            secp192r1: {
              p: 'fffffffffffffffffffffffffffffffeffffffffffffffff',
              a: 'fffffffffffffffffffffffffffffffefffffffffffffffc',
              b: '64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1',
              generator: %w[
                188da80eb03090f67cbf20eb43a18800f4ff0afd82ff1012
                07192b95ffc8da78631011ed6b24cdd573f977a11e794811
              ].freeze,
              n: 'ffffffffffffffffffffffff99def836146bc9b1b4d22831'
            },
            secp224k1: { # 112 bits of security
              p: 'fffffffffffffffffffffffffffffffffffffffffffffffeffffe56d',
              a: '00000000000000000000000000000000000000000000000000000000',
              b: '00000000000000000000000000000000000000000000000000000005',
              generator: %w[
                a1455b334df099df30fc28a169a467e9e47075a90f7e650eb6b7a45c
                7e089fed7fba344282cafbd6f7e319f7c0b0bd59e2ca4bdb556d61a5
              ].freeze,
              n: '010000000000000000000000000001dce8d2ec6184caf0a971769fb1f7'
            },
            secp224r1: { # 112 bits of security
              p: 'ffffffffffffffffffffffffffffffff000000000000000000000001',
              a: 'fffffffffffffffffffffffffffffffefffffffffffffffffffffffe',
              b: 'b4050a850c04b3abf54132565044b0b7d7bfd8ba270b39432355ffb4',
              generator: %w[
                b70e0cbd6bb4bf7f321390b94a03c1d356c21122343280d6115c1d21
                bd376388b5f723fb4c22dfe6cd4375a05a07476444d5819985007e34
              ].freeze,
              n: 'ffffffffffffffffffffffffffff16a2e0b8f03e13dd29455c5c2a3d'
            },
            secp256k1: { # 128 bits of security
              p: 'fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f',
              a: '0000000000000000000000000000000000000000000000000000000000000000',
              b: '0000000000000000000000000000000000000000000000000000000000000007',
              generator: %w[
                79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798
                483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8
              ].freeze,
              n: 'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141'
            },
            secp256r1: { # 128 bits of security
              p: 'ffffffff00000001000000000000000000000000ffffffffffffffffffffffff',
              a: 'ffffffff00000001000000000000000000000000fffffffffffffffffffffffc',
              b: '5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b',
              generator: %w[
                6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296
                4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5
              ].freeze,
              n: 'ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551'
            },
            secp384r1: { # 192 bits of security
              p: 'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff',
              a: 'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffff0000000000000000fffffffc',
              b: 'b3312fa7e23ee7e4988e056be3f82d19181d9c6efe8141120314088f5013875ac656398d8a2ed19d2a85c8edd3ec2aef',
              generator: %w[
                aa87ca22be8b05378eb1c71ef320ad746e1d3b628ba79b9859f741e082542a385502f25dbf55296c3a545e3872760ab7
                3617de4a96262c6f5d9e98bf9292dc29f8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f
              ].freeze,
              n: 'ffffffffffffffffffffffffffffffffffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973'
            }.freeze,
            # rubocop:disable Layout/LineLength
            secp521r1: { # 256 bits of security
              p: '01ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
              a: '01fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc',
              b: '0051953eb9618e1c9a1f929a21a0b68540eea2da725b99b315f3b8b489918ef109e156193951ec7e937b1652c0bd3bb1bf073573df883d2c34f1ef451fd46b503f00',
              generator: %w[
                00c6858e06b70404e9cd9e3ecb662395b4429c648139053fb521f828af606b4d3dbaa14b5e77efe75928fe1dc127a2ffa8de3348b3c1856a429bf97e7e31c2e5bd66
                011839296a789a3bc0045c8a5fb42c7d1bd998f54449579b446817afbd17273e662c97ee72995ef42640c550b9013fad0761353c7086a272c24088be94769fd16650
              ].freeze,
              n: '01fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa51868783bf2f966b7fcc0148f709a5d03bb5c9b8899c47aebb6fb71e91386409'
            }.freeze
            # rubocop:enable Layout/LineLength
          }.freeze

          attr_reader :curve, :n

          def initialize(algorithm, private_key = nil, public_key = nil)
            parameters = PARAMETERS[algorithm]
            raise 'unsupported algorithm' if parameters.nil?

            p = parameters[:p].to_i(16)
            a = parameters[:a].to_i(16)
            b = parameters[:b].to_i(16)

            @curve = Curve.new(a, b, p)
            @generator = Point.new(
              parameters[:generator][0].to_i(16),
              parameters[:generator][1].to_i(16)
            )
            @n = parameters[:n].to_i(16) || curve.order(@generator)

            unless private_key.nil?
              self.private_key = private_key
              generate_public_key! if public_key.nil?
            end

            self.public_key = public_key unless public_key.nil?
          end

          def generate_public_key!
            self.public_key = @curve.multiply(@generator, @private_key)
          end

          def private_key=(private_key)
            raise 'Private key out of range' unless private_key.positive? && private_key < @n

            @private_key = private_key
          end

          def public_key=(public_key)
            raise 'Invalid public key' unless @curve.valid?(public_key)
            raise 'Invalid public key' unless @curve.multiply(public_key, @n) == @curve.zero

            @public_key = public_key
          end

          # DigitalSignatureAlgorithm

          def sign(digest, entropy)
            raise 'Entropy out of range' unless entropy.positive? && entropy < @n

            m = @curve.multiply(@generator, entropy)
            Point.new(m.x, NumberTheory.modular_inverse(entropy, @n) * (digest + m.x * @private_key) % @n)
          end

          def verify(digest, signature)
            w = NumberTheory.modular_inverse(signature.y, @n)
            u1 = digest * w % @n
            u2 = signature.x * w % @n
            p = @curve.add(@curve.multiply(@generator, u1), @curve.multiply(@public_key, u2))

            p.x % @n == signature.x
          end

          # Diffie Hellman

          # my private_key
          # partner public_key
          def compute_secret(private_key, public_key)
            raise 'Private key out of range' unless private_key.positive? && private_key < @n
            raise 'Invalid public key' unless @curve.valid?(public_key)
            raise 'Invalid public key' unless @curve.multiply(public_key, @n) == @curve.zero

            @curve.multiply(public_key, private_key)
          end

          # ElGamal on ECC

          # plaintext is a point on the curve
          def encrypt(plaintext, entropy)
            raise 'Invalid plaintext value' unless @curve.valid?(plaintext)

            [@curve.multiply(@generator, entropy), @curve.add(plaintext, @curve.multiply(@public_key, entropy))]
          end

          # ciphertext is an array of two points on the curve
          def decrypt(ciphertext)
            c1, c2 = ciphertext
            raise 'Invalid ciphertext values' unless @curve.valid?(c1) && @curve.valid?(c2)

            @curve.add(c2, @curve.negate(@curve.multiply(c1, @private_key)))
          end
        end
      end
    end
  end
end

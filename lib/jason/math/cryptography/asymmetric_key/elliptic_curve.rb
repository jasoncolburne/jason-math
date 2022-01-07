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
          end

          # An elliptic curve
          class Curve
            attr_reader :a, :b, :n, :zero

            # (y**2 = x**3 + a * x + b) mod n
            def initialize(a, b, n)
              @a = a
              @b = b
              @n = n

              @zero = Point.new(0, 0)
            end

            def valid?(p)
              return true if p == @zero

              l = (p.y * p.y) % @n
              r = ((p.x * p.x * p.x) + @a * p.x + @b) % @n

              l == r
            end

            def negate(p)
              Point.new(p.x, -p.y % @n)
            end

            def add(p1, p2)
              return p2 if p1 == @zero
              return p1 if p2 == @zero

              # p1 + -p1 == 0
              return @zero if p1.x == p2.x && (p1.y != p2.y || p1.y.zero?)

              l = if p1.x == p2.x
                    (3 * p1.x * p1.x + @a) * NumberTheory.modular_inverse(2 * p1.y, @n) % @n
                  else
                    (p2.y - p1.y) * NumberTheory.modular_inverse(p2.x - p1.x, @n) % @n
                  end

              x = (l * l - p1.x - p2.x) % @n
              y = (l * (p1.x - x) - p1.y) % @n

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

              (1..(@n + 1)).each do |i|
                return i if multiply(p, i) == @zero
              end

              raise 'Invalid order'
            end
          end

          # include Math

          PARAMETERS = {
            secp112r1: {
              n: 'db7c2abf62e35e668076bead208b',
              a: 'db7c2abf62e35e668076bead2088',
              b: '659ef8ba043916eede8911702b22',
              generator: %w[
                09487239995a5ee76b55f9c2f098
                a89ce5af8724c0a23e0e0ff77500
              ].freeze,
              order: 'db7c2abf62e35e7628dfac6561c5'
            },
            secp128r1: {
              n: 'fffffffdffffffffffffffffffffffff',
              a: 'fffffffdfffffffffffffffffffffffc',
              b: 'e87579c11079f43dd824993c2cee5ed3',
              generator: %w[
                161ff7528b899b2d0c28607ca52c5b86
                cf5ac8395bafeb13c02da292dded7a83
              ].freeze,
              order: 'fffffffe0000000075a30d1b9038a115'
            },
            secp160r1: {
              n: 'ffffffffffffffffffffffffffffffff7fffffff',
              a: 'ffffffffffffffffffffffffffffffff7ffffffc',
              b: '1c97befc54bd7a8b65acf89f81d4d4adc565fa45',
              generator: %w[
                4a96b5688ef573284664698968c38bb913cbfc82
                23a628553168947d59dcc912042351377ac5fb32
              ].freeze,
              order: '0100000000000000000001f4c8f927aed3ca752257'
            },
            secp192r1: {
              n: 'fffffffffffffffffffffffffffffffeffffffffffffffff',
              a: 'fffffffffffffffffffffffffffffffefffffffffffffffc',
              b: '64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1',
              generator: %w[
                188da80eb03090f67cbf20eb43a18800f4ff0afd82ff1012
                07192b95ffc8da78631011ed6b24cdd573f977a11e794811
              ].freeze,
              order: 'ffffffffffffffffffffffff99def836146bc9b1b4d22831'
            },
            secp224r1: {
              n: 'ffffffffffffffffffffffffffffffff000000000000000000000001',
              a: 'fffffffffffffffffffffffffffffffefffffffffffffffffffffffe',
              b: 'b4050a850c04b3abf54132565044b0b7d7bfd8ba270b39432355ffb4',
              generator: %w[
                b70e0cbd6bb4bf7f321390b94a03c1d356c21122343280d6115c1d21
                bd376388b5f723fb4c22dfe6cd4375a05a07476444d5819985007e34
              ].freeze,
              order: 'ffffffffffffffffffffffffffff16a2e0b8f03e13dd29455c5c2a3d'
            },
            secp256r1: {
              n: 'ffffffff00000001000000000000000000000000ffffffffffffffffffffffff',
              a: 'ffffffff00000001000000000000000000000000fffffffffffffffffffffffc',
              b: '5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b',
              generator: %w[
                6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296
                4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5
              ].freeze,
              order: 'ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551'
            },
            secp384r1: {
              n: 'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff',
              a: 'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffff0000000000000000fffffffc',
              b: 'b3312fa7e23ee7e4988e056be3f82d19181d9c6efe8141120314088f5013875ac656398d8a2ed19d2a85c8edd3ec2aef',
              generator: %w[
                aa87ca22be8b05378eb1c71ef320ad746e1d3b628ba79b9859f741e082542a385502f25dbf55296c3a545e3872760ab7
                3617de4a96262c6f5d9e98bf9292dc29f8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f
              ].freeze,
              order: 'ffffffffffffffffffffffffffffffffffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973'
            }.freeze,
            # rubocop:disable Layout/LineLength
            secp521r1: {
              n: '01ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
              a: '01fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc',
              b: '0051953eb9618e1c9a1f929a21a0b68540eea2da725b99b315f3b8b489918ef109e156193951ec7e937b1652c0bd3bb1bf073573df883d2c34f1ef451fd46b503f00',
              generator: %w[
                00c6858e06b70404e9cd9e3ecb662395b4429c648139053fb521f828af606b4d3dbaa14b5e77efe75928fe1dc127a2ffa8de3348b3c1856a429bf97e7e31c2e5bd66
                011839296a789a3bc0045c8a5fb42c7d1bd998f54449579b446817afbd17273e662c97ee72995ef42640c550b9013fad0761353c7086a272c24088be94769fd16650
              ].freeze,
              order: '01fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa51868783bf2f966b7fcc0148f709a5d03bb5c9b8899c47aebb6fb71e91386409'
            }.freeze
            # rubocop:enable Layout/LineLength
          }.freeze

          attr_reader :curve

          def initialize(algorithm, private_key = nil, public_key = nil)
            parameters = PARAMETERS[algorithm]
            raise 'unsupported algorithm' if parameters.nil?

            a = parameters[:a].to_i(16)
            b = parameters[:b].to_i(16)
            n = parameters[:n].to_i(16)

            @curve = Curve.new(a, b, n)
            @generator = Point.new(
              parameters[:generator][0].to_i(16),
              parameters[:generator][1].to_i(16)
            )
            @order = parameters[:order].to_i(16) || curve.order(@generator)

            unless private_key.nil?
              self.private_key = private_key
              self.public_key = @curve.multiply(@generator, @private_key) if public_key.nil?
            end

            self.public_key = public_key unless public_key.nil?
          end

          def generate_public_key!
            self.public_key = @curve.multiply(@generator, @private_key)
          end

          def private_key=(private_key)
            raise 'Private key out of range' unless private_key.positive? && private_key < @order

            @private_key = private_key
          end

          def public_key=(public_key)
            raise 'Invalid public key' unless @curve.valid?(public_key)
            raise 'Invalid public key' unless @curve.multiply(public_key, @order) == @curve.zero

            @public_key = public_key
          end

          # DigitalSignatureAlgorithm

          def sign(digest, entropy)
            raise 'Entropy out of range' unless entropy.positive? && entropy < @order

            m = @curve.multiply(@generator, entropy)
            [m.x, NumberTheory.modular_inverse(entropy, @order) * (digest + m.x * @private_key) % @order]
          end

          def verify(digest, signature)
            w = NumberTheory.modular_inverse(signature[1], @order)
            u1 = digest * w % @order
            u2 = signature[0] * w % @order
            p = @curve.add(@curve.multiply(@generator, u1), @curve.multiply(@public_key, u2))

            p.x % @order == signature[0]
          end

          # Diffie Hellman

          # my private_key
          # partner public_key
          def compute_secret(private_key, public_key)
            raise 'Private key out of range' unless private_key.positive? && private_key < @order
            raise 'Invalid public key' unless @curve.valid?(public_key)
            raise 'Invalid public key' unless @curve.multiply(public_key, @order) == @curve.zero

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

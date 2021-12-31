# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      module AsymmetricKey
        module EllipticCurve
          # port of https://gist.github.com/bellbind/1414867/04ccbaa3fe97304d3d9d91c36520a662f2e28a45

          # A couple math routines used by ECC
          module Math
            def inverse(x, n)
              NumberTheory.modular_inverse(x, n)
            end

            # want to replace with an optimized version for prime n
            # but it breaks the naive tests (where n is 19).
            # should likely test with NIST params
            def sqrt(x, n)
              raise 'x must be < n' unless x < n

              (1..n).each do |i|
                return [i, n - i] if i * i % n == x
              end

              raise 'No root found'
            end
          end

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
            include Math

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

            def at(x)
              raise 'x must be < n' unless x < @n

              ysq = (x * x * x + @a * x + @b) % @n
              y, my = sqrt(ysq, @n)

              [Point.new(x, y), Point.new(x, my)]
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
                    (3 * p1.x * p1.x + @a) * inverse(2 * p1.y, @n) % @n
                  else
                    (p2.y - p1.y) * inverse(p2.x - p1.x, @n) % @n
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

          # Each algorithm shares this code
          class AlgorithmBase
            def initialize(curve, generator, order = nil)
              raise 'Invalid generator specified' unless curve.valid?(generator)

              @curve = curve
              @generator = generator
              @order = order || curve.order(generator)
            end

            def generate_public_key(private_key)
              raise 'Private key out of range' unless private_key.positive? && private_key < @order

              @curve.multiply(@generator, private_key)
            end
          end

          # ECDSA
          class DigitalSignatureAlgorithm < AlgorithmBase
            include Math

            def sign(digest, private_key, entropy)
              raise 'Entropy out of range' unless entropy.positive? && entropy < @order

              m = @curve.multiply(@generator, entropy)
              [m.x, inverse(entropy, @order) * (digest + m.x * private_key) % @order]
            end

            def verify(digest, signature, public_key)
              raise 'Invalid public key' unless @curve.valid?(public_key)
              raise 'Invalid public key' unless @curve.multiply(public_key, @order) == @curve.zero

              w = inverse(signature[1], @order)
              u1 = digest * w % @order
              u2 = signature[0] * w % @order
              p = @curve.add(@curve.multiply(@generator, u1), @curve.multiply(public_key, u2))

              p.x % @order == signature[0]
            end
          end

          # ECDH
          class DiffieHellman < AlgorithmBase
            # my private_key
            # partner public_key
            def compute_secret(private_key, public_key)
              raise 'Invalid public key' unless @curve.valid?(public_key)
              raise 'Invalid public key' unless @curve.multiply(public_key, @order) == @curve.zero

              @curve.multiply(public_key, private_key)
            end
          end

          # ElGamal on ECC
          class ElGamal < AlgorithmBase
            # plaintext is a point on the curve
            def encrypt(plaintext, public_key, entropy)
              raise 'Invalid plaintext value' unless @curve.valid?(plaintext)
              raise 'Invalid public key' unless @curve.valid?(public_key)

              [@curve.multiply(@generator, entropy), @curve.add(plaintext, @curve.multiply(public_key, entropy))]
            end

            # ciphertext is an array of two points on the curve
            def decrypt(ciphertext, private_key)
              c1, c2 = ciphertext
              raise 'Invalid ciphertext values' unless @curve.valid?(c1) && @curve.valid?(c2)

              @curve.add(c2, @curve.negate(@curve.multiply(c1, private_key)))
            end
          end
        end
      end
    end
  end
end
require 'securerandom'

module Jason
  module Math
    module Cryptography
      module EllipticCurve
        # port of https://gist.github.com/bellbind/1414867/04ccbaa3fe97304d3d9d91c36520a662f2e28a45

        module Math
          def extended_gcd(a, b)
            s0, s1, t0, t1 = 1, 0, 0, 1

            while b > 0
              q = a / b
              r = a % b
              a, b = b, r
              s0, s1, t0, t1 = s1, s0 - q * s1, t1, t0 - q * t1
            end

            [s0, t0, a]
          end

          def inverse(x, n)
            return extended_gcd(x, n)[0] % n
          end

          def sqrt(x, n)
            raise "x must be < n" unless x < n
            
            (1..n).each do |i|
              return [i, n - i] if i * i % n == x
            end

            raise "No root found"
          end                
        end

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
        end

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
            raise "x must be < n" unless x < @n
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
            return @zero if p1.x == p2.x && (p1.y != p2.y || p1.y == 0)

            if p1.x == p2.x
              l = (3 * p1.x * p1.x + @a) * inverse(2 * p1.y, @n) % @n
            else
              l = (p2.y - p1.y) * inverse(p2.x - p1.x, @n) % @n
            end

            x = (l * l - p1.x - p2.x) % @n
            y = (l * (p1.x - x) - p1.y) % @n

            Point.new(x, y)
          end

          def multiply(p, n)
            r = @zero
            m2 = p

            # O(log2(n)) add
            while 0 < n
              r = add(r, m2) if n & 1 == 1
              n, m2 = n >> 1, add(m2, m2)
            end

            r
          end

          def order(p)
            raise "Invalid order" unless valid?(p) and p != @zero

            (1..(@n + 1)).each do |i|
              return i if multiply(p, i) == @zero
            end
              
            raise "Invalid order"
          end
        end

        class AlgorithmBase
          def initialize(curve, p)
            raise "Invalid point specified" unless curve.valid?(p)

            @curve = curve
            @p = p
            @n = curve.order(p)
          end

          def generate_public_key(private_key)
            raise "Private key out of range" unless 0 < private_key && private_key < @n
            
            @curve.multiply(@p, private_key)
          end
        end

        class DigitalSignatureAlgorithm < AlgorithmBase
          include Math

          def sign(digest, private_key, entropy)
            raise "Entropy out of range" unless 0 < entropy && entropy < @n

            m = @curve.multiply(@p, entropy)
            [m.x, inverse(entropy, @n) * (digest + m.x * private_key) % @n]
          end

          def validate(digest, signature, public_key)
            raise "Invalid public key" unless @curve.valid?(public_key)
            raise "Invalid public key" unless @curve.multiply(public_key, @n) == @curve.zero

            w = inverse(signature[1], @n)
            u1, u2 = digest * w % @n, signature[0] * w % @n
            p = @curve.add(@curve.multiply(@p, u1), @curve.multiply(public_key, u2))

            p.x % @n == signature[0]
          end
        end

        class DiffieHellman < AlgorithmBase
          # my private_key
          # partner public_key
          def compute_secret(private_key, public_key)
            raise "Invalid public key" unless @curve.valid?(public_key)
            raise "Invalid public key" unless @curve.multiply(public_key, @n) == @curve.zero

            @curve.multiply(public_key, private_key)
          end
        end

        class ElGamal < AlgorithmBase
          # plaintext is a point on the curve
          def encrypt(plaintext, public_key, entropy)
            raise "Invalid plaintext value" unless @curve.valid?(plaintext)
            raise "Invalid public key" unless @curve.valid?(public_key)

            [@curve.multiply(@p, entropy), @curve.add(plaintext, @curve.multiply(public_key, entropy))]
          end

          # ciphertext is an array of two points on the curve
          def decrypt(ciphertext, private_key)
            c1, c2 = ciphertext
            raise "Invalid ciphertext values" unless @curve.valid?(c1) && @curve.valid?(c2)

            @curve.add(c2, @curve.negate(@curve.multiply(c1, private_key)))
          end
        end

      end
    end
  end
end

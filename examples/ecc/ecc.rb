# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'jason/math'
require 'securerandom'
require 'yaml'

class CurveService
  def initialize(curve)
    curves = YAML.load_file('./curves.yml')
    params = curves[curve]

    raise 'Unknown Curve Specified' if params.nil?

    hex_characters_required = params['hex_characters_required']
    @hex_characters_required = hex_characters_required

    @ecc = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve.new(curve.to_sym)
  end

  def generate_keypair
    private_key = SecureRandom.hex(@hex_characters_required).to_i(16) % @ecc.n
    @ecc.private_key = private_key
    public_key = @ecc.generate_public_key!

    {
      private_key: i_to_hex(private_key),
      public_key: public_key.to_hex(@hex_characters_required)
    }
  end

  def sign(digest, private_key)
    digest = digest.to_i(16) % @ecc.n
    @ecc.private_key = private_key.to_i(16)
    entropy = SecureRandom.hex(@hex_characters_required).to_i(16) % @ecc.n

    signature = @ecc.sign(digest, entropy)

    signature.map { |x| x.to_s(16).rjust(@hex_characters_required, '0') }.join
  end

  def verify(digest, public_key, signature)
    digest = digest.to_i(16) % @ecc.n
    signature = [hex_to_i(signature, 0), hex_to_i(signature, 1)]
    @ecc.public_key = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(hex_to_i(public_key, 0), hex_to_i(public_key, 1))

    @ecc.verify(digest, signature)
  end

  def encrypt(plaintext, public_key)
    raise 'Plaintext value too long' unless plaintext.b.length * 2 <= @hex_characters_required - 10

    entropy = SecureRandom.hex(@hex_characters_required).to_i(16) % @ecc.n
    @ecc.public_key = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(hex_to_i(public_key, 0), hex_to_i(public_key, 1))

    # we have 32 bits to play with in an attempt to find a point on the curve
    filler = 0
    while filler < 2**31
      # convert plaintext to a point
      padding = @hex_characters_required / 2 - plaintext.b.length - 4
      x_string = filler.to_s(16).rjust(8,
                                       '0') + plaintext.b.unpack1('H*') + [padding].pack('C').unpack1('H*') * padding
      x = x_string.to_i(16)

      filler += 1

      # check if we have found a quadratic residue
      x_prime = (x * x * x + @ecc.curve.a * x + @ecc.curve.b) % @ecc.n
      exponent = (@ecc.n - 1) / 2
      next unless x_prime.modular_exponentiation(exponent, @ecc.n) == 1

      y, = x_prime.modular_square_roots(@ecc.n)
      plaintext_point = Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(x, y)

      a, b = @ecc.encrypt(plaintext_point, entropy)
      return a.to_hex(@hex_characters_required) + b.to_hex(@hex_characters_required)
    end

    raise "Couldn't find a point on curve, try again"
  end

  def decrypt(ciphertext, private_key)
    ciphertext = [
      Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(hex_to_i(ciphertext, 0), hex_to_i(ciphertext, 1)),
      Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(hex_to_i(ciphertext, 2), hex_to_i(ciphertext, 3))
    ]
    @ecc.private_key = private_key.to_i(16)

    plaintext_point = @ecc.decrypt(ciphertext)
    plaintext = i_to_hex(plaintext_point.x)[8..]
    padding = plaintext[-2..].to_i(16)
    [plaintext].pack('H*')[0..(-padding - 1)]
  end

  private

  def hex_to_i(input, part)
    input[(part * @hex_characters_required)..((part + 1) * @hex_characters_required - 1)].to_i(16)
  end

  def i_to_hex(n)
    n.to_s(16).rjust(@hex_characters_required, '0')
  end
end

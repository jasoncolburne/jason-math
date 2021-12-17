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

    raise 'Unknown Curve Specified' unless params

    hex_characters_required = params['hex_characters_required']
    @hex_characters_required = hex_characters_required

    n = params['n'].to_i(16)
    a = params['a'].to_i(16)
    b = params['b'].to_i(16)
    x = hex_to_i(params['generator'], 0)
    y = hex_to_i(params['generator'], 1)
    order = params['order'].to_i(16)

    @curve = Jason::Math::Cryptography::EllipticCurve::Curve.new(a, b, n)
    @p = Jason::Math::Cryptography::EllipticCurve::Point.new(x, y)
    @order = order
  end

  def generate_keypair
    private_key = SecureRandom.hex(@hex_characters_required).to_i(16) % @curve.n

    @generator ||= Jason::Math::Cryptography::EllipticCurve::AlgorithmBase.new(@curve, @p, @order)
    public_key = @generator.generate_public_key(private_key)

    {
      private_key: i_to_hex(private_key),
      public_key: public_key.to_hex(@hex_characters_required)
    }
  end

  def sign(digest, private_key)
    @dsa ||= Jason::Math::Cryptography::EllipticCurve::DigitalSignatureAlgorithm.new(@curve, @p, @order)

    digest = digest.to_i(16) % @curve.n
    private_key = private_key.to_i(16)
    entropy = SecureRandom.hex(@hex_characters_required).to_i(16) % @curve.n

    signature = @dsa.sign(digest, private_key, entropy)

    signature.map { |x| x.to_s(16).rjust(@hex_characters_required, '0') }.join
  end

  def verify(digest, public_key, signature)
    @dsa ||= Jason::Math::Cryptography::EllipticCurve::DigitalSignatureAlgorithm.new(@curve, @p, @order)

    digest = digest.to_i(16) % @curve.n
    signature = [hex_to_i(signature, 0), hex_to_i(signature, 1)]
    public_key = Jason::Math::Cryptography::EllipticCurve::Point.new(hex_to_i(public_key, 0), hex_to_i(public_key, 1))

    @dsa.verify(digest, signature, public_key)
  end

  def encrypt(plaintext, public_key)
    raise 'Plaintext value too long' unless plaintext.b.length * 2 <= @hex_characters_required - 10

    @elgamal ||= Jason::Math::Cryptography::EllipticCurve::ElGamal.new(@curve, @p, @order)

    entropy = SecureRandom.hex(@hex_characters_required).to_i(16) % @curve.n
    public_key = Jason::Math::Cryptography::EllipticCurve::Point.new(hex_to_i(public_key, 0), hex_to_i(public_key, 1))

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
      x_prime = (x * x * x + @curve.a * x + @curve.b) % @curve.n
      exponent = (@curve.n - 1) / 2
      next unless x_prime.modular_exponentiation(exponent, @curve.n) == 1

      y, = x_prime.modular_square_roots(@curve.n)
      plaintext_point = Jason::Math::Cryptography::EllipticCurve::Point.new(x, y)

      a, b = @elgamal.encrypt(plaintext_point, public_key, entropy)
      return a.to_hex(@hex_characters_required) + b.to_hex(@hex_characters_required)
    end

    raise "Couldn't find a point on curve, try again"
  end

  def decrypt(ciphertext, private_key)
    @elgamal ||= Jason::Math::Cryptography::EllipticCurve::ElGamal.new(@curve, @p, @order)

    ciphertext = [
      Jason::Math::Cryptography::EllipticCurve::Point.new(hex_to_i(ciphertext, 0), hex_to_i(ciphertext, 1)),
      Jason::Math::Cryptography::EllipticCurve::Point.new(hex_to_i(ciphertext, 2), hex_to_i(ciphertext, 3))
    ]
    private_key = private_key.to_i(16)

    plaintext_point = @elgamal.decrypt(ciphertext, private_key)
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

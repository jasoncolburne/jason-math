RSpec.describe Jason::Math::Cryptography::EllipticCurve::DigitalSignatureAlgorithm do
  let(:dsa) { described_class.new(curve, point) }

  let(:a) { 1 }
  let(:b) { 18 }
  let(:n) { 19 }
  let(:curve) { Jason::Math::Cryptography::EllipticCurve::Curve.new(a, b, n) }

  let(:point_x_value) { 7 }
  let(:point) { curve.at(point_x_value)[0] }

  let(:digest) { 128 }

  context "#sign" do
    subject { dsa.sign(digest, private_key, entropy) }

    let(:private_key) { 11 }
    let(:entropy) { 7 }
    let(:expected_signature) { [15, 12] }

    it { is_expected.to eq(expected_signature) }
  end

  context "#validate" do
    subject { dsa.verify(digest, signature, public_key) }

    let(:public_key) { Jason::Math::Cryptography::EllipticCurve::Point.new(1, 1) }

    context "valid signature" do
      let(:signature) { [15, 12] }

      it { is_expected.to be_truthy }
    end

    context "invalid signature" do
      let(:signature) { [15, 11] }

      it { is_expected.to be_falsey }
    end
  end
end

RSpec.describe Jason::Math::Cryptography::EllipticCurve::DiffieHellman do
  context "#compute_secret" do
    let(:dh) { described_class.new(curve, point) }

    let(:a) { 1 }
    let(:b) { 18 }
    let(:n) { 19 }
    let(:curve) { Jason::Math::Cryptography::EllipticCurve::Curve.new(a, b, n) }

    let(:point_x_value) { 7 }
    let(:point) { curve.at(point_x_value)[0] }

    let(:private_key_a) { 11 }
    let(:private_key_b) { 3 }
    let(:private_key_c) { 7 }

    let(:public_key_a) { dh.generate_public_key(private_key_a) }
    let(:public_key_b) { dh.generate_public_key(private_key_b) }
    let(:public_key_c) { dh.generate_public_key(private_key_c) }

    it "ensures secrets match for associated keypairs" do
      expect(dh.compute_secret(private_key_a, public_key_b)).to eq(dh.compute_secret(private_key_b, public_key_a))
      expect(dh.compute_secret(private_key_a, public_key_c)).to eq(dh.compute_secret(private_key_c, public_key_a))
      expect(dh.compute_secret(private_key_c, public_key_b)).to eq(dh.compute_secret(private_key_b, public_key_c))
    end

    it "ensures secrets do not match for unmatched keys" do
      expect(dh.compute_secret(private_key_a, public_key_b)).not_to eq(dh.compute_secret(private_key_a, public_key_c))
      expect(dh.compute_secret(private_key_b, public_key_a)).not_to eq(dh.compute_secret(private_key_b, public_key_c))
      expect(dh.compute_secret(private_key_c, public_key_a)).not_to eq(dh.compute_secret(private_key_c, public_key_b))
    end
  end
end

RSpec.describe Jason::Math::Cryptography::EllipticCurve::ElGamal do
  let(:eg) { described_class.new(curve, point) }

  let(:a) { 1 }
  let(:b) { 18 }
  let(:n) { 19 }
  let(:curve) { Jason::Math::Cryptography::EllipticCurve::Curve.new(a, b, n) }

  let(:point_x_value) { 7 }
  let(:point) { curve.at(point_x_value)[0] }

  let(:plaintext) { Jason::Math::Cryptography::EllipticCurve::Point.new(15, 11) }
  let(:ciphertext) { [
    Jason::Math::Cryptography::EllipticCurve::Point.new(8, 14),
    Jason::Math::Cryptography::EllipticCurve::Point.new(16, 8),
  ] }

  context "#encrypt" do
    subject { eg.encrypt(plaintext, public_key, entropy) }

    let(:public_key) { Jason::Math::Cryptography::EllipticCurve::Point.new(13, 10) }
    let(:entropy) { 15 }

    it { is_expected.to eq(ciphertext) }
  end

  context "#decrypt" do
    subject { eg.decrypt(ciphertext, private_key) }

    let(:private_key) { 5 }

    it { is_expected.to eq(plaintext) }
  end
end

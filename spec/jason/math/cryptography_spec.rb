require 'securerandom'

RSpec.describe Jason::Math::Cryptography do
  context "#hamming_distance cryptopals example" do
    subject { described_class.hamming_distance(a, b) }

    let(:a) { 'this is a test'.b }
    let(:b) { 'wokka wokka!!!'.b }
    it { is_expected.to eq(37) }
  end

  context "#pad_pkcs7 cryptopals example" do
    subject { described_class.pad_pkcs7(input, block_size) }

    let(:input) { "YELLOW SUBMARINE" }
    let(:block_size) { 20 }
    it { is_expected.to eq("YELLOW SUBMARINE\x04\x04\x04\x04".b) }
  end
end

RSpec.describe Jason::Math::Cryptography::Cipher do
  context "#detect_ecb?" do
    subject { described_class.detect_ecb?(cipher_text) }
    let(:key) { SecureRandom.random_bytes(16) }
    let(:initialization_vector) { SecureRandom.random_bytes(16) }
    let(:header_length) { SecureRandom.random_number(5) + 5 }
    let(:footer_length) { SecureRandom.random_number(5) + 5 }
    let(:header) { SecureRandom.random_bytes(header_length) }
    let(:footer) { SecureRandom.random_bytes(footer_length) }
    let(:cipher) { described_class.new(algorithm, key) }
    let(:cipher_text) { cipher.encrypt(clear_text, initialization_vector) }

    # overridden at times
    let(:clear_text) { header + "A" * 48 + footer }

    context "correctly detects when ecb encrypted" do
      let(:algorithm) { :aes_128_ecb }

      it { is_expected.to eq true }
    end

    context "does not detect when text not repeated" do
      let(:algorithm) { :aes_128_ecb }
      let(:clear_text) { SecureRandom.random_bytes(64) }

      it { is_expected.to eq false }
    end

    context "does not detect when cbc encrypted" do
      let(:algorithm) { :aes_128_cbc }

      it { is_expected.to eq false }
    end
  end
end

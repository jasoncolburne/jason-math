require 'securerandom'

RSpec.describe Jason::Math::Cryptography do
  context '#hamming_distance cryptopals example' do
    subject { described_class.hamming_distance(a, b) }

    let(:a) { 'this is a test'.b }
    let(:b) { 'wokka wokka!!!'.b }
    it { is_expected.to eq(37) }
  end
end

RSpec.describe Jason::Math::Cryptography::PKCS7 do
  let(:block_size) { 16 }
  let(:unpadded_data) { 'ICE ICE BABY' }
  let(:padded_data) { "ICE ICE BABY\x04\x04\x04\x04".b }

  context '#pad' do
    subject { described_class.pad(longer_unpadded_data, block_size) }

    context 'pads the second block' do
      let(:longer_unpadded_data) { 'j' * (block_size + 1) }
      let(:padding) { [block_size - 1] * (block_size - 1) }
      it { is_expected.to eq((longer_unpadded_data + padding.pack('C*')).b) }
    end

    context 'adds a full block if already a multiple of block_size' do
      let(:longer_unpadded_data) { 'j' * block_size }
      let(:padding) { [block_size] * block_size }
      it { is_expected.to eq((longer_unpadded_data + padding.pack('C*')).b) }
    end
  end

  context '#pad_block' do
    subject { described_class.pad_block(unpadded_data, block_size) }
    it { is_expected.to eq padded_data }
  end

  context '#strip' do
    subject { described_class.strip(padded_data, block_size) }
    it { is_expected.to eq unpadded_data }
  end

  context '#validate' do
    subject { described_class.validate(padded_data, block_size) }

    context 'raises no exceptions when correctly padded' do
      it { subject }
    end

    context 'raises exception when not a multiple of block size' do
      let(:padded_data) { "ICE ICE BABY BABY\x04\x04\x04\x04".b }
      it { expect { subject }.to raise_error }
    end

    context 'raises exception when padded with incorrect data' do
      let(:padded_data) { "ICE ICE BABY\x01\x02\x03\x04".b }
      it { expect { subject }.to raise_error }
    end

    context 'raises exception when padding length longer than block size' do
      let(:padded_data) { ('0123456789abcde' + "\x11" * 0x11).b }
      it { expect { subject }.to raise_error }
    end

    context 'raises exception when padded with zero' do
      let(:padded_data) { "0123456789abcde\x00".b }
      it { expect { subject }.to raise_error }
    end
  end
end

class Encryptor
  def initialize(algorithm, key_length, add_prefix = true, add_suffix = true, prefix_length = nil, suffix_length = nil)
    @prefix = if add_prefix
                SecureRandom.random_bytes(prefix_length || SecureRandom.random_number(32))
              else
                ''
              end
    @suffix = if add_suffix
                SecureRandom.random_bytes(suffix_length || SecureRandom.random_number(32))
              else
                ''
              end
    @initialization_vector = SecureRandom.random_bytes(16)
    @cipher = Jason::Math::Cryptography::Cipher.new(algorithm, SecureRandom.random_bytes(key_length))
  end

  def encrypt(clear_text)
    @cipher.encrypt(@prefix + clear_text + @suffix, @initialization_vector)
  end
end

RSpec.describe Jason::Math::Cryptography::Cipher do
  context '#detect_ecb?' do
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
    let(:clear_text) { header + 'A' * 48 + footer }

    context 'correctly detects when ecb encrypted' do
      let(:algorithm) { :aes_128_ecb }

      it { is_expected.to eq true }
    end

    context 'does not detect when text not repeated' do
      let(:algorithm) { :aes_128_ecb }
      let(:clear_text) { SecureRandom.random_bytes(64) }

      it { is_expected.to eq false }
    end

    context 'does not detect when cbc encrypted' do
      let(:algorithm) { :aes_128_cbc }

      it { is_expected.to eq false }
    end
  end

  context '#block_size' do
    subject { described_class.block_size(encryptor, maximum_block_size) }
    let(:maximum_block_size) { 128 }
    let(:block_size) { 16 }
    let(:add_prefix) { true }
    let(:add_suffix) { true }
    let(:encryptor) { Encryptor.new(algorithm, key_length, add_prefix, add_suffix) }

    context 'detects in 128-bit ecb' do
      let(:algorithm) { :aes_128_ecb }
      let(:key_length) { 16 }
      it { is_expected.to eq block_size }
    end

    context 'detects in 256-bit cbc' do
      let(:algorithm) { :aes_256_cbc }
      let(:key_length) { 32 }
      it { is_expected.to eq block_size }
    end

    context 'fails to detect when maximum block size is smaller than block size' do
      let(:algorithm) { :aes_128_ecb }
      let(:key_length) { 16 }
      let(:maximum_block_size) { 14 }
      let(:add_prefix) { false }
      let(:add_suffix) { false }
      it { expect { subject }.to raise_error }
    end

    context 'detects when maximum block size is equal to block size' do
      let(:algorithm) { :aes_128_ecb }
      let(:key_length) { 16 }
      let(:maximum_block_size) { 16 }
      it { is_expected.to eq block_size }
    end
  end

  context '#count_clear_text_extra_bytes' do
    subject { described_class.count_clear_text_extra_bytes(encryptor, block_size) }
    # don't feel the best about randomizing these inputs but
    # don't want to work out the edge cases right now
    let(:prefix_length) { SecureRandom.random_number(32) }
    let(:suffix_length) { SecureRandom.random_number(32) }
    let(:block_size) { 16 }
    let(:encryptor) { Encryptor.new(algorithm, key_length, true, true, prefix_length, suffix_length) }

    context 'aes 128 ecb' do
      let(:key_length) { 16 }
      let(:algorithm) { :aes_128_ecb }
      it { is_expected.to eq(prefix_length + suffix_length) }
    end

    context 'aes 192 cbc' do
      let(:key_length) { 24 }
      let(:algorithm) { :aes_192_cbc }
      it { is_expected.to eq(prefix_length + suffix_length) }
    end
  end

  context '#count_clear_text_prefix_bytes' do
    subject { described_class.count_clear_text_prefix_bytes(encryptor, block_size) }
    # don't feel the best about randomizing these inputs but
    # don't want to work out the edge cases right now
    let(:prefix_length) { SecureRandom.random_number(32) }
    let(:suffix_length) { SecureRandom.random_number(32) }
    let(:block_size) { 16 }
    let(:encryptor) { Encryptor.new(algorithm, key_length, true, true, prefix_length, suffix_length) }

    context 'aes 128 ecb' do
      let(:key_length) { 16 }
      let(:algorithm) { :aes_128_ecb }
      it { is_expected.to eq(prefix_length) }
    end

    context 'aes 192 cbc' do
      let(:key_length) { 24 }
      let(:algorithm) { :aes_192_cbc }
      it { is_expected.to eq(prefix_length) }
    end
  end
end

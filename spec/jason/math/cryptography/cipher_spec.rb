class Cryptor
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
    @cipher.initialization_vector = @initialization_vector
    @cipher.encrypt(@prefix + clear_text + @suffix)
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
    let(:cipher_text) { cipher.encrypt(clear_text) }

    # overridden at times
    let(:clear_text) { header + 'A' * 48 + footer }

    context 'correctly detects when repeated text is ecb encrypted' do
      let(:algorithm) { :aes_128_ecb }

      it { is_expected.to eq true }
    end

    context 'does not detect when text not repeated' do
      let(:algorithm) { :aes_128_ecb }
      let(:clear_text) { SecureRandom.random_bytes(64) }

      it { is_expected.to eq false }
    end

    context 'does not detect when cbc encrypted' do
      before do
        cipher.initialization_vector = initialization_vector
      end

      let(:algorithm) { :aes_128_cbc }

      it { is_expected.to eq false }
    end
  end

  context '#block_size' do
    subject { described_class.block_size(cryptor, maximum_block_size) }
    let(:maximum_block_size) { 128 }
    let(:block_size) { 16 }
    let(:add_prefix) { true }
    let(:add_suffix) { true }
    let(:cryptor) { Cryptor.new(algorithm, key_length, add_prefix, add_suffix) }

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
    subject { described_class.count_clear_text_extra_bytes(cryptor, block_size) }
    # don't feel the best about randomizing these inputs but
    # don't want to work out the edge cases right now
    let(:prefix_length) { SecureRandom.random_number(32) }
    let(:suffix_length) { SecureRandom.random_number(32) }
    let(:block_size) { 16 }
    let(:cryptor) { Cryptor.new(algorithm, key_length, true, true, prefix_length, suffix_length) }

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
    subject { described_class.count_clear_text_prefix_bytes(cryptor, block_size) }
    # don't feel the best about randomizing these inputs but
    # don't want to work out the edge cases right now
    let(:prefix_length) { SecureRandom.random_number(32) }
    let(:suffix_length) { SecureRandom.random_number(32) }
    let(:block_size) { 16 }
    let(:cryptor) { Cryptor.new(algorithm, key_length, true, true, prefix_length, suffix_length) }

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

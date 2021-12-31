RSpec.describe Jason::Math::Cryptography::Digest::Blake do
  subject { digest_machine.digest(message).byte_string_to_hex }
  let(:digest_machine) { described_class.new(algorithm, output_length, key) }
  let(:message) { 'The quick brown fox jumps over the lazy dog' }
  let(:key) { '' }
  let(:output_length) { 64 }

  context 'blake2b' do
    let(:algorithm) { :'2b' }

    context 'empty message' do
      let(:message) { '' }
      it { is_expected.to eq('786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce') }
    end

    context 'short message' do
      it { is_expected.to eq("a8add4bdddfd93e4877d2746e62817b116364a1fa7bc148d95090bc7333b3673f82401cf7aa2e4cb1ecd90296e3f14cb5413f8ed77be73045b13914cdcd6a918") }
    end

    context 'byte by byte' do
      let(:message) { '' }

      before do
        real_message = 'The quick brown fox jumps over the lazy dog'
        real_message.each_char { |character| digest_machine << character }
      end

      it { is_expected.to eq("a8add4bdddfd93e4877d2746e62817b116364a1fa7bc148d95090bc7333b3673f82401cf7aa2e4cb1ecd90296e3f14cb5413f8ed77be73045b13914cdcd6a918") }
    end

    context 'long message' do
      let(:message) { 'mathematics!' * 256 }

      it { is_expected.to eq("a21fafc9fa3326c22728ca4926abbb24d05b7660865aebc45812046c38133edd628e6bc9bc733c38170b33aa0da5aacfba7b6c759e82c247a27191e4995e9f60") }
    end

    context 'empty message, 384 bits' do
      let(:output_length) { 48 }
      let(:message) { '' }

      it { is_expected.to eq('b32811423377f52d7862286ee1a72ee540524380fda1724a6f25d7978c6fd3244a6caf0498812673c5e05ef583825100') }
    end

    context 'abc, output changed to 256 bits' do
      let(:message) { 'abc' }

      before do
        digest_machine.output_length = 32
      end
    
      it { is_expected.to eq('bddd813c634239723171ef3fee98579b94964e3bb1cb3e427262c8c068d52319') }
    end

    context 'keyed, long message' do
      let(:message) { 'mathematics!' * 256 }
      let(:key) { '0123456789abcdefghijklmnopqrstuvwxyz' }

      it { is_expected.to eq("ebe002dd373a8a76076547a079b6a9df3f901f2fb0c5e86a8884276f9d75f42a6688b57e40b2c346d33de53347f99a9a7d33ed205683468ead8fac4c46f3a127") }
    end
  end
end

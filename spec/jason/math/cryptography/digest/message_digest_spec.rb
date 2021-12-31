RSpec.describe Jason::Math::Cryptography::Digest::MessageDigest do
  context 'md4' do
    subject { digest_machine.digest(message) }
    let(:digest_machine) { described_class.new(:'4') }

    context 'empty message' do
      let(:message) { '' }
      it { is_expected.to eq("1\xD6\xCF\xE0\xD1j\xE91\xB7<Y\xD7\xE0\xC0\x89\xC0".b) }
    end

    context 'short message' do
      let(:message) { 'I pity the fool!' }
      it { is_expected.to eq("\xD1\ahB\xCD\xB2\x82\x974\xCD\xB6\r\x89\xE1D\x17".b) }
    end

    context 'byte by byte' do
      let(:message) { '' }

      before do
        real_message = 'I pity the fool!'
        real_message.each_char { |character| digest_machine << character }
      end

      it { is_expected.to eq("\xD1\ahB\xCD\xB2\x82\x974\xCD\xB6\r\x89\xE1D\x17".b) }
    end

    context 'long message' do
      let(:message) { 'mathematics!' * 256 }

      it { is_expected.to eq("\x85\xACE\xA3\x1F\x11eO\x1A\x85\b@\x12.r1".b) }
    end
  end
end

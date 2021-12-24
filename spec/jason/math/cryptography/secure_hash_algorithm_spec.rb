RSpec.describe Jason::Math::Cryptography::SecureHashAlgorithm do
  context 'sha 1' do
    subject { digest_machine.digest(message) }
    let(:digest_machine) { described_class.new(:'1') }

    context 'empty message' do
      let(:message) { '' }
      it { is_expected.to eq("\xDA9\xA3\xEE^kK\r2U\xBF\xEF\x95`\x18\x90\xAF\xD8\a\t".b) }
    end

    context 'short message' do
      let(:message) { 'I pity the fool!' }
      it { is_expected.to eq("\xAAQ0R\xD9\xBF\x05]Ng\xE3\x0F\xD9\xA7 \xF8\t\xA0'\xEF".b) }
    end

    context 'byte by byte' do
      let(:message) { '' }

      before do
        real_message = 'I pity the fool!'
        real_message.each_char { |character| digest_machine << character }
      end

      it { is_expected.to eq("\xAAQ0R\xD9\xBF\x05]Ng\xE3\x0F\xD9\xA7 \xF8\t\xA0'\xEF".b) }
    end

    context 'long message' do
      let(:message) { 'mathematics!' * 256 }

      it { is_expected.to eq("\xAE\xE4\x01\x9F\x95\x00XTA\x89R\vW\xC0gH\x94\xF4\xD0\x8B".b) }
    end
  end
end

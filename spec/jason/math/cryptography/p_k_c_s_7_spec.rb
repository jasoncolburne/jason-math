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
      let(:padded_data) { "0123456789abcde#{"\x11" * 0x11}".b }
      it { expect { subject }.to raise_error }
    end

    context 'raises exception when padded with zero' do
      let(:padded_data) { "0123456789abcde\x00".b }
      it { expect { subject }.to raise_error }
    end
  end
end

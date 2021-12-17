# frozen_string_literal: true

RSpec.describe Jason::Math::Utility do
  context '#binary_search' do
    subject { described_class.binary_search(array, value) }

    context 'for 13 in [1, 5, 7, 13, 22]' do
      let(:array) { [1, 5, 7, 13, 22] }
      let(:value) { 13 }
      it { is_expected.to eq(3) }
    end

    context 'for 94 in [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94]' do
      let(:array) { [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94] }
      let(:value) { 94 }
      it { is_expected.to eq(18) }
    end

    context 'for 4 in [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94]' do
      let(:array) { [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94] }
      let(:value) { 4 }
      it { is_expected.to eq(0) }
    end

    context 'for 3 in [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94]' do
      let(:array) { [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94] }
      let(:value) { 3 }
      it { is_expected.to eq(nil) }
    end
  end

  context '#neighbouring_cells' do
    subject { described_class.neighbouring_cells(cell) }

    context 'for [0]' do
      let(:cell) { [0] }
      it { is_expected.to eq([[-1], [1]]) }
    end

    context 'for [1, 1]' do
      let(:cell) { [1, 1] }
      it { is_expected.to eq([[0, 0], [1, 0], [2, 0], [0, 1], [2, 1], [0, 2], [1, 2], [2, 2]]) }
    end

    context 'for [1, 2, 3, 4, 5, 6], count' do
      subject { described_class.neighbouring_cells(cell).count }
      let(:cell) { [1, 2, 3, 4, 5, 6] }
      it { is_expected.to eq(728) }
    end

    context 'for []' do
      let(:cell) { [] }
      it { is_expected.to eq([]) }
    end
  end

  context '#adjacent_cells' do
    subject { described_class.adjacent_cells(cell) }

    context 'for [0]' do
      let(:cell) { [0] }
      it { is_expected.to eq([[-1], [1]]) }
    end

    context 'for [1, 1]' do
      let(:cell) { [1, 1] }
      it { is_expected.to eq([[0, 1], [2, 1], [1, 0], [1, 2]]) }
    end

    context 'for [1, 1, -1]' do
      let(:cell) { [1, 1, -1] }
      it { is_expected.to eq([[0, 1, -1], [2, 1, -1], [1, 0, -1], [1, 2, -1], [1, 1, -2], [1, 1, 0]]) }
    end

    context 'for [1, 2, 3, 4, 5, 6], count' do
      subject { described_class.adjacent_cells(cell).count }
      let(:cell) { [1, 2, 3, 4, 5, 6] }
      it { is_expected.to eq(12) }
    end

    context 'for []' do
      let(:cell) { [] }
      it { is_expected.to eq([]) }
    end
  end

  context '#hex_to_base64' do
    subject { described_class.hex_to_base64(hex_string) }

    context 'cryptopals example' do
      let(:hex_string) do
        '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
      end
      it { is_expected.to eq("SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hy\nb29t\n") }
    end
  end

  context '#byte_string_to_base64' do
    subject { described_class.byte_string_to_base64(byte_string) }

    context 'simple example' do
      let(:byte_string) { 'some text to encode' }
      it { is_expected.to eq("c29tZSB0ZXh0IHRvIGVuY29kZQ==\n") }
    end
  end

  context '#base64_to_byte_string' do
    subject { described_class.base64_to_byte_string(base64_string) }

    context 'simple example' do
      let(:base64_string) { "c29tZSB0ZXh0IHRvIGVuY29kZQ==\n" }
      it { is_expected.to eq('some text to encode') }
    end
  end

  context '#hex_to_byte_array' do
    subject { described_class.hex_to_byte_array(hex_string) }

    context 'simple example' do
      let(:hex_string) { 'ff00' }
      it { is_expected.to eq([255, 0]) }
    end
  end

  context '#hex_to_byte_string' do
    subject { described_class.hex_to_byte_string(hex_string) }

    context 'simple example' do
      let(:hex_string) { 'ff00' }
      it { is_expected.to eq("\xff\x00".b) }
    end
  end

  context '#byte_string_to_hex' do
    subject { described_class.byte_string_to_hex(byte_string) }

    context 'simple example' do
      let(:byte_string) { "\xff\x00".b }
      it { is_expected.to eq('ff00') }
    end
  end

  context '#xor' do
    subject { described_class.xor(a, b) }

    context 'cryptopals example' do
      let(:a) { '1c0111001f010100061a024b53535009181c'.hex_to_byte_string }
      let(:b) { '686974207468652062756c6c277320657965'.hex_to_byte_string }

      it { is_expected.to eq('746865206b696420646f6e277420706c6179'.hex_to_byte_string) }
    end
  end
end

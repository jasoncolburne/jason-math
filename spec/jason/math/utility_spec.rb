RSpec.describe Jason::Math::Utility do
  context "#binary_search" do
    subject { described_class.binary_search(array, value) }

    context "for 13 in [1, 5, 7, 13, 22]" do
      let(:array) { [1, 5, 7, 13, 22] }
      let(:value) { 13 }
      it { is_expected.to eq(3) }
    end

    context "for 94 in [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94]" do
      let(:array) { [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94] }
      let(:value) { 94 }
      it { is_expected.to eq(18) }
    end

    context "for 4 in [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94]" do
      let(:array) { [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94] }
      let(:value) { 4 }
      it { is_expected.to eq(0) }
    end

    context "for 3 in [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94]" do
      let(:array) { [4, 5, 17, 21, 22, 24, 32, 36, 43, 57, 67, 71, 73, 76, 77, 88, 89, 90, 94] }
      let(:value) { 3 }
      it { is_expected.to eq(nil) }
    end
  end

  context "#neighbouring_cells" do
    subject { described_class.neighbouring_cells(cell) }

    context "for [0]" do
      let(:cell) { [0] }
      it { is_expected.to eq([[-1], [1]]) }
    end

    context "for [1, 1]" do
      let(:cell) { [1, 1] }
      it { is_expected.to eq([[0, 0], [1, 0], [2, 0], [0, 1], [2, 1], [0, 2], [1, 2], [2, 2]]) }
    end

    context "for [1, 2, 3, 4, 5, 6], count" do
      subject { described_class.neighbouring_cells(cell).count }
      let(:cell) { [1, 2, 3, 4, 5, 6] }
      it { is_expected.to eq(728) }
    end

    context "for []" do
      let(:cell) { [] }
      it { is_expected.to eq([]) }
    end
  end

  context "#adjacent_cells" do
    subject { described_class.adjacent_cells(cell) }

    context "for [0]" do
      let(:cell) { [0] }
      it { is_expected.to eq([[-1], [1]]) }
    end

    context "for [1, 1]" do
      let(:cell) { [1, 1] }
      it { is_expected.to eq([[0, 1], [2, 1], [1, 0], [1, 2]]) }
    end

    context "for [1, 1, -1]" do
      let(:cell) { [1, 1, -1] }
      it { is_expected.to eq([[0, 1, -1], [2, 1, -1], [1, 0, -1], [1, 2, -1], [1, 1, -2], [1, 1, 0]]) }
    end

    context "for [1, 2, 3, 4, 5, 6], count" do
      subject { described_class.adjacent_cells(cell).count }
      let(:cell) { [1, 2, 3, 4, 5, 6] }
      it { is_expected.to eq(12) }
    end

    context "for []" do
      let(:cell) { [] }
      it { is_expected.to eq([]) }
    end
  end

  context "#hex_to_base64" do
    subject { described_class.hex_to_base64(hex_string) }

    context "cryptopals example" do
      let(:hex_string) { '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d' }
      it { is_expected.to eq('SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t') }
    end
  end
end

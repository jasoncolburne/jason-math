RSpec.describe Jason::Math::Analysis do
  context "#collatz_sequence" do
    subject { described_class.collatz_sequence(n) }

    context "for 13" do
      let(:n) { 13 }
      it { is_expected.to eq([13, 40, 20, 10, 5, 16, 8, 4, 2, 1]) }
    end
  end

  context "#root_as_continued_fraction" do
    subject { described_class.root_as_continued_fraction(n) }

    context "for 13" do
      let(:n) { 13 }
      it { is_expected.to eq([3, [1, 1, 1, 1, 6]]) }
    end

    context "for 94" do
      let(:n) { 94 }
      it { is_expected.to eq([9, [1, 2, 3, 1, 1, 5, 1, 8, 1, 5, 1, 1, 3, 2, 1, 18]]) }
    end
  end
end

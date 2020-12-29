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

    context "for 1" do
      let(:n) { 1 }
      it { is_expected.to eq([1, []]) }
    end
  end

  context "#evaluate_continued_fraction" do
    subject { described_class.evaluate_continued_fraction(fraction, depth) }
    let(:depth) { 42 }

    context "for phi ([1, [1]])" do
      let(:fraction) { [1, [1]] }
      let(:result) { Rational(701408733, 433494437) }
      it { is_expected.to eq(result) }
    end

    context "for root 2 ([1, [2]])" do
      let(:fraction) { [1, [2]] }
      let(:result) { Rational(14398739476117879, 10181446324101389) }
      it { is_expected.to eq(result) }
    end

    context "for root 2 ([1, [2]]), depth = 0" do
      let(:fraction) { [1, [2]] }
      let(:depth) { 0 }
      let(:result) { 1 }
      it { is_expected.to eq(result) }
    end

    context "for root 2 ([1, [2]]), depth = 1" do
      let(:fraction) { [1, [2]] }
      let(:depth) { 1 }
      let(:result) { Rational(3, 2) }
      it { is_expected.to eq(result) }
    end

    context "for root 2 ([1, [2]]), depth = 8" do
      let(:fraction) { [1, [2]] }
      let(:depth) { 8 }
      let(:result) { Rational(1393, 985) }
      it { is_expected.to eq(result) }
    end

    context "for [3, [1, 1, 1, 1, 6]]" do
      let(:fraction) { [3, [1, 1, 1, 1, 6]] }
      let(:result) { Rational(20169517848487, 5594017754162) }
      it { is_expected.to eq(result) }
    end

    context "for [9, [1, 2, 3, 1, 1, 5, 1, 8, 1, 5, 1, 1, 3, 2, 1, 18]]" do
      let(:fraction) { [9, [1, 2, 3, 1, 1, 5, 1, 8, 1, 5, 1, 1, 3, 2, 1, 18]] }
      let(:result) { Rational(1562560820373993102, 161165842870530659) }
      it { is_expected.to eq(result) }
    end
  end
end

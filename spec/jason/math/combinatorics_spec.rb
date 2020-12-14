RSpec.describe Jason::Math::Combinatorics do
  context "#factorial" do
    subject { described_class.factorial(n) }

    context "for 13" do
      let(:n) { 13 }
      it { is_expected.to eq(6227020800) }
    end

    context "for 0" do
      let(:n) { 0 }
      it { is_expected.to eq(1) }
    end

    context "for 1" do
      let(:n) { 1 }
      it { is_expected.to eq(1) }
    end
  end

  context "#n_choose_k" do
    subject { described_class.n_choose_k(n, k) }

    context "40c20" do
      let(:n) { 40 }
      let(:k) { 20 }
      it { is_expected.to eq(137846528820) }
    end
  end
end
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

  context "#nCk" do
    subject { described_class.nCk(n, k) }

    context "40C20" do
      let(:n) { 40 }
      let(:k) { 20 }
      it { is_expected.to eq(137846528820) }
    end
  end

  context "#nPk" do
    subject { described_class.nPk(n, k) }

    context "40P20" do
      let(:n) { 40 }
      let(:k) { 20 }
      it { is_expected.to eq(335367096786357081410764800000) }
    end
  end
end

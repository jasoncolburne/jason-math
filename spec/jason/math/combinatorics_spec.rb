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

  context "#double_factorial" do
    subject { described_class.double_factorial(n) }

    context "for 13" do
      let(:n) { 13 }
      it { is_expected.to eq(135135) }
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

  context "#enumerate_partitions" do
    subject { described_class.enumerate_partitions(array).to_a }

    context "for [1, 2, 3]" do
      let(:array) { [1, 2, 3] }
      it { is_expected.to eq([[[1, 2, 3]], [[1, 2], [3]], [[1, 3], [2]], [[1], [2, 3]], [[1], [2], [3]]]) }
    end
  end

  context "#enumerate_integer_partitions" do
    subject { described_class.enumerate_integer_partitions(n).to_a }

    context "for 4" do
      let(:n) { 4 }
      it { is_expected.to eq([[1, 1, 1, 1], [1, 1, 2], [1, 3], [2, 2], [4]]) }
    end
  end

  context "#count_integer_partitions" do
    subject { described_class.count_integer_partitions(n) }

    context "for 42" do
      let(:n) { 42 }
      it { is_expected.to eq(53174) }
    end
  end
end

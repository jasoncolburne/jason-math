RSpec.describe Jason::Math::Algebra do
  context "#solve_quadratic" do
    subject { described_class.solve_quadratic(a, b, c) }

    context "x^2 - 1" do
      let(:a) { 1 }
      let(:b) { 0 }
      let(:c) { -1 }
      it { is_expected.to eq([1.0, -1.0]) }
    end

    context "x^2 + 1" do
      let(:a) { 1 }
      let(:b) { 0 }
      let(:c) { 1 }
      it { is_expected.to eq([Complex(0.0, 1.0), Complex(0.0, -1.0)]) }
    end

    context "x^2" do
      let(:a) { 1 }
      let(:b) { 0 }
      let(:c) { 0 }
      it { is_expected.to eq([0.0]) }
    end
  end
end
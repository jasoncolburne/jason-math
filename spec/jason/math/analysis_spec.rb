RSpec.describe Jason::Math::Analysis do
  context "#collatz_sequence" do
    subject { described_class.collatz_sequence(n) }

    context "for 13" do
      let(:n) { 13 }
      it { is_expected.to eq([13, 40, 20, 10, 5, 16, 8, 4, 2, 1]) }
    end
  end
end
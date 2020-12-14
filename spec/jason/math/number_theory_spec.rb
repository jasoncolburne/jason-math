require 'set'

RSpec.describe Jason::Math::NumberTheory do
  context "#primes" do
    subject { described_class.primes(count) }

    context "first 10" do
      let(:count) { 10 }
      it { is_expected.to eq(Set[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]) }
    end
  end

  context "#primes_below" do
    subject { described_class.primes_below(limit) }

    context "below 29" do
      let(:limit) { 29 }
      it { is_expected.to eq(Set[2, 3, 5, 7, 11, 13, 17, 19, 23]) }
    end
  end

  context "#factors" do
    subject { described_class.factors(n) }

    context "of #{ 2*2*2*3*5*5*7*7*7*11*13*17*17*19 }" do
      let(:n) { 2*2*2*3*5*5*7*7*7*11*13*17*17*19 }
      it { is_expected.to eq({2=>3, 3=>1, 5=>2, 7=>3, 11=>1, 13=>1, 17=>2, 19=>1}) }
    end
  end

  context "#divisors" do
    subject { described_class.divisors(n) }

    context "of 24" do
      let(:n) { 24 }
      it { is_expected.to eq(Set[1, 2, 3, 4, 6, 8, 12, 24]) }
    end
  end

  context "#co_prime?" do
    subject { described_class.co_prime?(numbers) }

    context "for [2, 3, 5, 7, 11, 13, 17, 19]" do
      let(:numbers) { [2, 3, 5, 7, 11, 13, 17, 19] }
      it { is_expected.to be_truthy }
    end

    context "for [2, 3, 5, 7, 9, 11, 13, 17, 19]" do
      let(:numbers) { [2, 3, 5, 7, 9, 11, 13, 17, 19] }
      it { is_expected.to be_falsey }
    end
  end

  context "#chinese_remainder_theorem" do
    subject { described_class.chinese_remainder_theorem(values_by_moduli) }

    context "where x is congruent to 3 (mod 5), 5 (mod 7), 4 (mod 9)" do
      let(:values_by_moduli) { { 5=>3, 7=>5, 9=>4 } }
      it { is_expected.to eq(103) }
    end
  end

  context "#triangular_number" do
    subject { described_class.triangular_number(n) }

    context "10th triangular number" do
      let(:n) { 10 }
      it { is_expected.to eq(55) }
    end
  end

  context "#perfect?" do
    subject { described_class.perfect?(n) }

    context "28" do
      let(:n) { 28 }
      it { is_expected.to be_truthy }
    end

    context "12" do
      let(:n) { 12 }
      it { is_expected.to be_falsey }
    end

    context "2" do
      let(:n) { 2 }
      it { is_expected.to be_falsey }
    end
  end

  context "#deficient?" do
    subject { described_class.deficient?(n) }

    context "28" do
      let(:n) { 28 }
      it { is_expected.to be_falsey }
    end

    context "12" do
      let(:n) { 12 }
      it { is_expected.to be_falsey }
    end

    context "2" do
      let(:n) { 2 }
      it { is_expected.to be_truthy }
    end
  end

  context "#abundant?" do
    subject { described_class.abundant?(n) }

    context "28" do
      let(:n) { 28 }
      it { is_expected.to be_falsey }
    end

    context "12" do
      let(:n) { 12 }
      it { is_expected.to be_truthy }
    end

    context "2" do
      let(:n) { 2 }
      it { is_expected.to be_falsey }
    end
  end
end
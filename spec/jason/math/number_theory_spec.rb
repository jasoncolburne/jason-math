require 'set'

RSpec.describe Jason::Math::NumberTheory do
  context "#primes" do
    subject { described_class.primes(count) }

    context "first 10" do
      let(:count) { 10 }
      it { is_expected.to eq([2, 3, 5, 7, 11, 13, 17, 19, 23, 29]) }
    end
  end

  context "#primes_below" do
    subject { described_class.primes_below(limit) }

    context "below 29" do
      let(:limit) { 29 }
      it { is_expected.to eq([2, 3, 5, 7, 11, 13, 17, 19, 23]) }
    end
  end

  context "#factors" do
    subject { described_class.factors(n) }

    context "of #{ 2*2*2*3*5*5*7*7*7*11*13*17*17*19 }" do
      let(:n) { 2*2*2*3*5*5*7*7*7*11*13*17*17*19 }
      it { is_expected.to eq({2=>3, 3=>1, 5=>2, 7=>3, 11=>1, 13=>1, 17=>2, 19=>1}) }
    end

    context "of #{ 5 }" do
      let(:n) { 5 }
      it { is_expected.to eq({5=>1}) }
    end
  end

  context "#prime" do
    subject { described_class.prime(offset) }

    context "1st" do
      let(:offset) { 1 }
      it { is_expected.to eq(2) }
    end

    context "100000th" do
      let(:offset) { 100000 }
      it { is_expected.to eq(1299709) }
    end
  end

  context "#prime?" do
    subject { described_class.prime?(n) }

    context "2" do
      let(:n) { 2 }
      it { is_expected.to be_truthy }
    end

    context "4" do
      let(:n) { 4 }
      it { is_expected.to be_falsey }
    end

    context "17" do
      let(:n) { 17 }
      it { is_expected.to be_truthy }
    end

    context "25" do
      let(:n) { 25 }
      it { is_expected.to be_falsey }
    end

    context "1299709 (100000th prime)" do
      let(:n) { 1299709 }
      it { is_expected.to be_truthy }
    end

    context "1299709 * 1299721 (100000th and 100001st primes)" do
      let(:n) { 1299709 * 1299721 }
      it { is_expected.to be_falsey }
    end
  end

  context "#divisors" do
    subject { described_class.divisors(n) }

    context "of 24" do
      let(:n) { 24 }
      it { is_expected.to eq(Set[1, 2, 3, 4, 6, 8, 12, 24]) }
    end

    context "of 17" do
      let(:n) { 17 }
      it { is_expected.to eq(Set[1,17]) }
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

    context "for [2, 26]" do
      let(:numbers) { [2, 26] }
      it { is_expected.to be_falsey }
    end

    context "for [2, 32193213281156929]" do
      # this tests that we return early even if prime < root_max_n if we have resolved
      # all but one number to 1. if this test runs super slowly, you fucked up.
      let(:numbers) { [2, 32193213281156929] }
      it { is_expected.to be_truthy }
    end

    context "for [1, 4]" do
      # 1 is coprime with everything
      let(:numbers) { [1, 4] }
      it { is_expected.to be_truthy }
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

  context "#palindrome?" do
    subject { described_class.palindrome?(n) }

    context "71317" do
      let(:n) { 71317 }
      it { is_expected.to be_truthy }
    end

    context "24566" do
      let(:n) { 24566 }
      it { is_expected.to be_falsey }
    end
  end

  context "#lychrel?" do
    subject { described_class.lychrel?(n, depth) }

    context "47" do
      let(:n) { 47 }
      let(:depth) { 1 }
      it { is_expected.to be_falsey }
    end

    context "349, depth 3" do
      let(:n) { 349 }
      let(:depth) { 3 }
      it { is_expected.to be_falsey }
    end

    context "349, depth 2" do
      let(:n) { 349 }
      let(:depth) { 2 }
      it { is_expected.to be_truthy }
    end

    context "196, depth 1000" do
      let(:n) { 196 }
      let(:depth) { 1000 }
      it { is_expected.to be_truthy }
    end
  end

  context "#reverse" do
    subject { described_class.reverse(n) }

    context "9294745263867334858" do
      let(:n) { 9294745263867334858 }
      it { is_expected.to eq(8584337683625474929) }
    end
  end
end
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

  context "#prime_factors" do
    subject { described_class.prime_factors(n) }

    context "of #{ 2*2*2*3*5*5*7*7*7*11*13*17*17*19 }" do
      let(:n) { 2*2*2*3*5*5*7*7*7*11*13*17*17*19 }
      it { is_expected.to eq({2=>3, 3=>1, 5=>2, 7=>3, 11=>1, 13=>1, 17=>2, 19=>1}) }
    end
  end
end
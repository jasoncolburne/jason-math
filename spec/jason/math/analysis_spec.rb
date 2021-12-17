# frozen_string_literal: true

RSpec.describe Jason::Math::Analysis do
  context '#collatz_sequence' do
    subject { described_class.collatz_sequence(n) }

    context 'for 13' do
      let(:n) { 13 }
      it { is_expected.to eq([13, 40, 20, 10, 5, 16, 8, 4, 2, 1]) }
    end
  end

  context '#fibonacci_enumerator' do
    context 'first 10' do
      subject { described_class.fibonacci_enumerator.first(n) }
      let(:n) { 10 }
      it { is_expected.to eq([0, 1, 1, 2, 3, 5, 8, 13, 21, 34]) }
    end
  end

  context '#fibonacci_term' do
    subject { described_class.fibonacci_term(n) }

    context '10th' do
      let(:n) { 10 }
      it { is_expected.to eq(55) }
    end
  end

  context '#root_as_continued_fraction' do
    subject { described_class.root_as_continued_fraction(n) }

    context 'for 13' do
      let(:n) { 13 }
      it { is_expected.to eq([3, [1, 1, 1, 1, 6]]) }
    end

    context 'for 94' do
      let(:n) { 94 }
      it { is_expected.to eq([9, [1, 2, 3, 1, 1, 5, 1, 8, 1, 5, 1, 1, 3, 2, 1, 18]]) }
    end

    context 'for 1' do
      let(:n) { 1 }
      it { is_expected.to eq([1, []]) }
    end
  end

  context '#evaluate_continued_fraction' do
    subject { described_class.evaluate_continued_fraction(fraction, depth) }
    let(:depth) { 42 }

    context 'for phi ([1, [1]])' do
      let(:fraction) { [1, [1]] }
      let(:result) { Rational(701_408_733, 433_494_437) }
      it { is_expected.to eq(result) }
    end

    context 'for root 2 ([1, [2]])' do
      let(:fraction) { [1, [2]] }
      let(:result) { Rational(14_398_739_476_117_879, 10_181_446_324_101_389) }
      it { is_expected.to eq(result) }
    end

    context 'for root 2 ([1, [2]]), depth = 0' do
      let(:fraction) { [1, [2]] }
      let(:depth) { 0 }
      let(:result) { 1 }
      it { is_expected.to eq(result) }
    end

    context 'for root 2 ([1, [2]]), depth = 1' do
      let(:fraction) { [1, [2]] }
      let(:depth) { 1 }
      let(:result) { Rational(3, 2) }
      it { is_expected.to eq(result) }
    end

    context 'for root 2 ([1, [2]]), depth = 8' do
      let(:fraction) { [1, [2]] }
      let(:depth) { 8 }
      let(:result) { Rational(1393, 985) }
      it { is_expected.to eq(result) }
    end

    context 'for [3, [1, 1, 1, 1, 6]]' do
      let(:fraction) { [3, [1, 1, 1, 1, 6]] }
      let(:result) { Rational(20_169_517_848_487, 5_594_017_754_162) }
      it { is_expected.to eq(result) }
    end

    context 'for [9, [1, 2, 3, 1, 1, 5, 1, 8, 1, 5, 1, 1, 3, 2, 1, 18]]' do
      let(:fraction) { [9, [1, 2, 3, 1, 1, 5, 1, 8, 1, 5, 1, 1, 3, 2, 1, 18]] }
      let(:result) { Rational(1_562_560_820_373_993_102, 161_165_842_870_530_659) }
      it { is_expected.to eq(result) }
    end
  end
end

# frozen_string_literal: true

RSpec.describe Jason::Math::Cryptography::PseudoRandomNumberGeneration::MersenneTwister19937 do
  context '32-bit' do
    let(:prng) { described_class.new(:mt19937) }

    context 'correct first number' do
      subject { prng.extract_number }
      it { is_expected.to eq(0xd091bb5c) }
    end

    context 'correct 10000th number' do
      subject { (1..10_000).map { prng.extract_number }.last }
      it { is_expected.to eq(4_123_659_995) }
    end

    context '#untemper yields correct results' do
      subject { described_class.untemper(tempered_value) }

      let(:untempered_value) { 0x69 }
      let(:tempered_value) { prng.send(:temper, untempered_value) }
      it { is_expected.to eq(untempered_value) }
    end
  end

  context '64-bit' do
    let(:prng) { described_class.new(:mt19937_64) }

    context 'correct first number' do
      subject { prng.extract_number }
      it { is_expected.to eq(0xc96d191cf6f6aea6) }
    end

    context 'correct 10000th number' do
      subject { (1..10_000).map { prng.extract_number }.last }
      it { is_expected.to eq(9_981_545_732_273_789_042) }
    end
  end
end

# frozen_string_literal: true

require 'securerandom'

RSpec.describe Jason::Math::Cryptography do
  context '#hamming_distance cryptopals example' do
    subject { described_class.hamming_distance(a, b) }

    let(:a) { 'this is a test'.b }
    let(:b) { 'wokka wokka!!!'.b }
    it { is_expected.to eq(37) }
  end

  context '#secure_compare' do
    subject { described_class.secure_compare(byte_string_to_test, known_byte_string) }
    let(:known_byte_string) { 'this is a test' }

    context 'matches' do
      let(:byte_string_to_test) { known_byte_string }
      it { is_expected.to be_truthy }
    end

    context 'matches' do
      let(:byte_string_to_test) { 'this is a teat' }
      it { is_expected.to be_falsey }
    end
  end
end

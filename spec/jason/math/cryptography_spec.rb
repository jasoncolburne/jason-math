# frozen_string_literal: true

require 'securerandom'

RSpec.describe Jason::Math::Cryptography do
  context '#hamming_distance cryptopals example' do
    subject { described_class.hamming_distance(a, b) }

    let(:a) { 'this is a test'.b }
    let(:b) { 'wokka wokka!!!'.b }
    it { is_expected.to eq(37) }
  end
end

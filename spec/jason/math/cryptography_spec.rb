RSpec.describe Jason::Math::Cryptography do
  context "#hamming_distance cryptopals example" do
    subject { described_class.hamming_distance(a, b) }

    let(:a) { 'this is a test'.b }
    let(:b) { 'wokka wokka!!!'.b }
    it { is_expected.to eq(37) }
  end

  context "#pad_pkcs7 cryptopals example" do
    subject { described_class.pad_pkcs7(input, block_size) }

    let(:input) { "YELLOW SUBMARINE" }
    let(:block_size) { 20 }
    it { is_expected.to eq("YELLOW SUBMARINE\x04\x04\x04\x04".b) }
  end
end

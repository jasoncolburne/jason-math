RSpec.describe Jason::Math::Cryptography do
  context "#xor_cipher cryptopals example" do
    subject { described_class.xor_cipher(plaintext, key) }

    let(:plaintext) { "Burning 'em, if you ain't quick and nimble" }
    let(:key) { "ICE" }
    it { is_expected.to eq('0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20'.hex_to_byte_string) }
  end

  context "#hamming_distance cryptopals example" do
    subject { described_class.hamming_distance(a, b) }

    let(:a) { 'this is a test'.b }
    let(:b) { 'wokka wokka!!!'.b }
    it { is_expected.to eq(37) }
  end
end

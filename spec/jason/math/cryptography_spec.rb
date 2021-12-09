RSpec.describe Jason::Math::Cryptography do
  context "#xor_cipher" do
    subject { described_class.xor_cipher(plaintext, key) }

    let(:plaintext) { "Burning 'em, if you ain't quick and nimble" }
    let(:key) { "ICE" }
    it { is_expected.to eq('0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20'.hex_to_byte_string) }
  end
end

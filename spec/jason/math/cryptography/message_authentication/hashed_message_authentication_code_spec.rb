RSpec.describe Jason::Math::Cryptography::MessageAuthentication::HashedMessageAuthenticationCode do
  subject { hmac_machine.tag(message).byte_string_to_hex }
  let(:hmac_machine) { Jason::Math::Cryptography::MessageAuthentication::HashedMessageAuthenticationCode.new(algorithm, key) }
  let(:key) { "\x0b" * 20 }
  let(:message) { "Hi There" }

  context 'hmac-sha1' do
    let(:algorithm) { :sha_1 }
    it { is_expected.to eq('b617318655057264e28bc0b6fb378c8ef146be00') }
  end

  context 'hmac-sha-224' do
    let(:algorithm) { :sha_224 }
    it { is_expected.to eq('896fb1128abbdf196832107cd49df33f47b4b1169912ba4f53684b22') }
  end

  context 'hmac-sha-256' do
    let(:algorithm) { :sha_256 }
    it { is_expected.to eq('b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7') }
  end

  context 'hmac-sha-384' do
    let(:algorithm) { :sha_384 }
    it { is_expected.to eq('afd03944d84895626b0825f4ab46907f15f9dadbe4101ec682aa034c7cebc59cfaea9ea9076ede7f4af152e8b2fa9cb6') }
  end

  context 'hmac-sha-512' do
    let(:algorithm) { :sha_512 }
    it { is_expected.to eq('87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b30545e17cdedaa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f1702e696c203a126854') }
  end

  context 'hmac-sha-512/224' do
    let(:algorithm) { :sha_512_224 }
    it { is_expected.to eq('b244ba01307c0e7a8ccaad13b1067a4cf6b961fe0c6a20bda3d92039') }
  end

  context 'hmac-sha-512/256' do
    let(:algorithm) { :sha_512_256 }
    it { is_expected.to eq('9f9126c3d9c3c330d760425ca8a217e31feae31bfe70196ff81642b868402eab') }
  end

  context 'hmac-sha3-224' do
    let(:algorithm) { :sha_3_224 }
    it { is_expected.to eq('3b16546bbc7be2706a031dcafd56373d9884367641d8c59af3c860f7') }
  end

  context 'hmac-sha3-256' do
    let(:algorithm) { :sha_3_256 }
    it { is_expected.to eq('ba85192310dffa96e2a3a40e69774351140bb7185e1202cdcc917589f95e16bb') }
  end

  context 'hmac-sha3-384' do
    let(:algorithm) { :sha_3_384 }
    it { is_expected.to eq('68d2dcf7fd4ddd0a2240c8a437305f61fb7334cfb5d0226e1bc27dc10a2e723a20d370b47743130e26ac7e3d532886bd') }
  end

  context 'hmac-sha3-512' do
    let(:algorithm) { :sha_3_512 }
    it { is_expected.to eq('eb3fbd4b2eaab8f5c504bd3a41465aacec15770a7cabac531e482f860b5ec7ba47ccb2c6f2afce8f88d22b6dc61380f23a668fd3888bb80537c0a0b86407689e') }
  end
end
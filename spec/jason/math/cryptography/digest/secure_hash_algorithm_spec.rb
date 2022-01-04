# https://www.di-mgt.com.au/sha_testvectors.html

RSpec.describe Jason::Math::Cryptography::Digest::SecureHashAlgorithm do
  subject { digest_machine.digest(message).byte_string_to_hex }
  let(:digest_machine) { described_class.new(algorithm) }
  let(:message) { 'abc' }

  context 'sha 1' do
    let(:algorithm) { :'1' }

    context 'empty message' do
      let(:message) { '' }
      it { is_expected.to eq("da39a3ee5e6b4b0d3255bfef95601890afd80709") }
    end

    context 'short message' do
      it { is_expected.to eq("a9993e364706816aba3e25717850c26c9cd0d89d") }
    end

    context 'byte by byte' do
      let(:message) { '' }

      before do
        real_message = 'abc'
        real_message.each_char { |character| digest_machine << character }
      end

      it { is_expected.to eq("a9993e364706816aba3e25717850c26c9cd0d89d") }
    end

    context 'long message' do
      let(:message) { 'mathematics!' * 256 }

      it { is_expected.to eq("aee4019f950058544189520b57c0674894f4d08b") }
    end
  end

  context 'sha 224' do
    let(:algorithm) { :'224' }

    context 'short message' do
      it { is_expected.to eq("23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7") }
    end
  end

  context 'sha 256' do
    let(:algorithm) { :'256' }

    context 'short message' do
      it { is_expected.to eq("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad") }
    end
  end

  context 'sha 384' do
    let(:algorithm) { :'384' }

    context 'short message' do
      it { is_expected.to eq("cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7") }
    end
  end

  context 'sha 512' do
    let(:algorithm) { :'512' }

    context 'short message' do
      it { is_expected.to eq("ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f") }
    end
  end

  # https://wtools.io/sha512-224-generator-online
  context 'sha 512/224' do
    let(:algorithm) { :'512_224' }

    context 'short message' do
      it { is_expected.to eq("4634270f707b6a54daae7530460842e20e37ed265ceee9a43e8924aa") }
    end
  end

  # https://wtools.io/sha512-256-generator-online
  context 'sha 512/256' do
    let(:algorithm) { :'512_256' }

    context 'short message' do
      it { is_expected.to eq("53048e2681941ef99b2e29b76b4c7dabe4c2d0c634fc6d46e0e2f13107e7af23") }
    end
  end

  context 'shake128' do
    let(:algorithm) { :shake128 }

    context 'short message' do
      it { is_expected.to eq('5881092dd818bf5cf8a3ddb793fbcba74097d5c526a6d35f97b83351940f2cc8') }
    end
  end

  context 'shake256' do
    let(:algorithm) { :shake256 }

    context 'short message' do
      it { is_expected.to eq('483366601360a8771c6863080cc4114d8db44530f8f1e1ee4f94ea37e78b5739d5a15bef186a5386c75744c0527e1faa9f8726e462a12a4feb06bd8801e751e4') }
    end
  end

  context 'sha 3/224' do
    let(:algorithm) { :'3_224' }

    context 'short message' do
      it { is_expected.to eq('e642824c3f8cf24ad09234ee7d3c766fc9a3a5168d0c94ad73b46fdf') }
    end
  end

  context 'sha 3/256' do
    let(:algorithm) { :'3_256' }

    context 'short message' do
      it { is_expected.to eq('3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532') }
    end
  end

  context 'sha 3/384' do
    let(:algorithm) { :'3_384' }

    context 'short message' do
      it { is_expected.to eq('ec01498288516fc926459f58e2c6ad8df9b473cb0fc08c2596da7cf0e49be4b298d88cea927ac7f539f1edf228376d25') }
    end
  end

  context 'sha 3/512' do
    let(:algorithm) { :'3_512' }

    context 'short message' do
      it { is_expected.to eq('b751850b1a57168a5693cd924b6b096e08f621827444f70d884f5d0240d2712e10e116e9192af3c91a7ec57647e3934057340b4cf408d5a56592f8274eec53f0') }
    end

    context 'longer message' do
      let(:message) { 'i am the bomb' * 6 }
      it { is_expected.to eq('d57b76d956b896ad4dc4b2a29326fd4b16ff16a678ace1dda0d95c309cb78e98ecad1b991018c400f95426948c4750da5265ce0f91996b5f08104b296a77ebeb') }
    end
  end
end

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
end

RSpec.describe Jason::Math::Cryptography::KeyEncapsulation::StreamlinedNTRUPrime do
  context 'integration' do
    subject { sntrup.decapsulate(cipher_text) }
    let(:parameters) { :sntrup653 }
    let(:sntrup) { described_class.new(parameters) }
    let(:encapsulation) { sntrup.encapsulate }
    let(:cipher_text) { encapsulation[0] }
    let(:session_key) { encapsulation[1] }

    before(:each) { sntrup.generate_keypair }
    it { is_expected.to eq(session_key) }
  end
end

RSpec.describe Jason::Math::Cryptography::KeyStretching::Argon2 do
  subject { kdf.derive(password, salt, associated_data).byte_string_to_hex }
  let(:kdf) { described_class.new(parallelism, tag_length, memory_size, iterations, key, hash_type) }
  let(:password) { "\x01" * 32 }
  let(:salt) { "\x02" * 16 }
  let(:parallelism) { 4 }
  let(:tag_length) { 32 }
  let(:memory_size) { 32 }
  let(:iterations) { 3 }
  let(:key) { "\x03" * 8 }
  let(:associated_data) { "\x04" * 12 }

  context 'argon2' do
    context '(argon2d)' do
      let(:hash_type) { :argon2d }
      it { is_expected.to eq('512b391b6f1162975371d30919734294f868e3be3984f3c1a13a4db9fabe4acb') }
    end

    context '(argon2i)' do
      let(:hash_type) { :argon2i }
      it { is_expected.to eq('c814d9d1dc7f37aa13f0d77f2494bda1c8de6b016dd388d29952a4c4672b6ce8') }
    end

    context '(argon2id)' do
      let(:hash_type) { :argon2id }
      it { is_expected.to eq('0d640df58d78766c08c037a34a8b53c9d01ef0452d75b65eb52520e96b01e659') }
    end
  end
end

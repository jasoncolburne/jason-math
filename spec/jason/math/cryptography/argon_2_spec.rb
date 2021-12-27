RSpec.describe Jason::Math::Cryptography::Argon2 do
  subject { kdf.derive(password, associated_data).byte_string_to_hex }
  let(:kdf) { described_class.new(salt, parallelism, tag_length, memory_size, iterations, key, hash_type) }
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
  end
end

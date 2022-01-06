RSpec.describe Jason::Math::Cryptography::AsymmetricKey::RivestShamirAdleman do
  let(:rsa) { described_class.new(algorithm, modulus, private_key, public_key) }
  let(:public_key) { 65_537 }

  context '1024-bit' do
    let(:algorithm) { :'1024' }
    let(:private_key) { 21300912969361830187197096533404041678180757873709732606302389722629354787091801089067918699131463205480592490570550237761854394394582425742248280281029665610197590017542436560342179466320084204710990111837041240161984967744816595757664654379806773854079774282598682852717004705592263357652366312981457386841 }
    let(:modulus) { 97156831490626458223080774994585425024388929169315846874707848087967430468151537597817739345441674781472080596758336008087041197441469077208457775326432228719132489990437049254780158840743510774898710760111558778795373451975793045215435815882090652459477001282063105864332689146072202769408292157008719220787 }
    
    context 'signatures' do
      let(:digest) { "my wacky digest".b.byte_string_to_integer }
      let(:signature) { 35545148901383540238107226984024133529802769441270450418671491898760053713320281403246413349043869613480391559814141931286729415224604174431656651370032153408957616446421451506173240551517352639255143028439285321578234237482677630681652336198742320901198717323236086893030740783839936113588892148441347912319 }

      context 'signs' do
        subject { rsa.sign(digest) }
        it { is_expected.to eq(signature) }
      end

      context 'verifies' do
        subject { rsa.verify(digest, signature) }
        it { is_expected.to be_truthy }
      end

      context 'fails to verify when digest altered' do
        subject { rsa.verify(digest + 1, signature) }
        it { is_expected.to be_falsey }
      end

      context 'fails to verify when signature altered' do
        subject { rsa.verify(digest, signature + 1) }
        it { is_expected.to be_falsey }
      end
    end

    context 'encryption' do
      let(:clear_text) { "some cleartext".b.byte_string_to_integer }
      let(:cipher_text) { 73309925115574135158115288265166472547104464965749751091818009325793972806608964141701080348769939388193524778465507900671036148599537188046098907330536935625005867193486063843478557332342410810819494271634120027536084084871694080800803592936147471833662778779860339003304713415119419227108268835219844389508 }

      context 'encrypts' do
        subject { rsa.encrypt(clear_text) }
        it { is_expected.to eq(cipher_text) }
      end

      context 'raises when clear_text larger than modulus' do
        subject { rsa.encrypt(long_clear_text) }
        let(:long_clear_text) { ("j".b * 129).byte_string_to_integer }
        it { expect { subject }.to raise_error }
      end

      context 'decrypts' do
        subject { rsa.decrypt(cipher_text) }
        it { is_expected.to eq(clear_text) }
      end
    end
  end
end

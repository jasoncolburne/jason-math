RSpec.describe Jason::Math::Cryptography::AsymmetricKey::DigitalSignatureAlgorithm do
  let(:p) { 89884656743115795386465259539451236680898848947115328636715040578866337902750481566354238661203768010560056939935696678829394884407208311246423715319737062188883946712432742638151109800623047059726541476042502884419075341171231440736956555270413618581675257121929646867022661084025768359855730363041859302841 }
  let(:q) { 1352163916521028315202592366204697982936273899937 }
  let(:g) { 42899366730247106636776959075783142721033447185855272195818996250494592553393965849030347706803104792441317390491025063660842462267342493233669659933234818917872627046244275691170815629127011570172026748924659104330312801744482591981834287265058889006229634610603874974803154054961449006438406680567862497735 }
  let(:x) { nil }
  let(:y) { nil }

  let(:message) { '666' }

  let(:hash_algorithm) { :sha_1 }
  let(:parameter_set) { :'1024' }
  let(:dsa) { described_class.new(hash_algorithm, parameter_set, p, q, g, x, y) }

  context 'signs' do
    subject { dsa.sign(message) }
    before { allow(SecureRandom).to receive(:random_number) { 9 } }

    let(:x) { 1228863141481530079957959051098192452371655882620 }

    it { is_expected.to eq([929184144486099295622701011417932210603515367545, 1197441980808931358489390556887945154756527637773]) }
  end

  context 'verification' do
    subject { dsa.verify(message, r, s) }

    let(:r) { 252333200527490479927429495376939202918222384927 }
    let(:s) { 1144390751553387598538559649012047732953395994947 }
    let(:y) { 14490238162507116421538928807633823130351499178565472253928624153481261391991535425195824351516098888683597662046552588645612408818208844724184932088796145518032492738341002637094582930550784070002142340283242870128612110417832821047190178207952001907365633112660383359781385911904700680496519925954851391545 }
   
    context 'verifies' do
      it { is_expected.to be_truthy }
    end

    context 'fails to verify if r incorrect' do
      let(:r) { 252333200527490479927429495376939202918222384927 + 1 }
      it { is_expected.to be_falsey }
    end

    context 'fails to verify if s incorrect' do
      let(:s) { 1144390751553387598538559649012047732953395994947 + 1 }
      it { is_expected.to be_falsey }
    end

    context 'fails to verify if message does not match' do
      let(:message) { '667' }
      it { is_expected.to be_falsey }
    end
  end
end
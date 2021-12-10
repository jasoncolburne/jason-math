RSpec.describe Jason::Math::Utility::LanguageDetector do
  context "#distance" do
    subject { described_class.distance(text, language) }
    let(:language) { :english }

    context "english text, language = :english" do
      let(:text) { "What art thou that usurp'st this time of night, together with that fair and warlike form in which the majesty of buried Denmark did sometimes march? by heaven I charge thee, speak!".b }
      it { is_expected.to be < 0.45 }
    end

    context "arabic text, language = :english" do
      let(:text) { "كن لا بد أن أوضح لك أن كل هذه الأفكار المغلوطة حول استنكار  النشوة وتمجيد الألم نشأت بالفعل، وسأعرض لك التفاصيل لتكتشف حقيقة وأساس تلك السعادة البشرية، فلا أحد يرفض أو يكره أو يتجنب الشعور بالسعادة، ولكن بفضل هؤلاء الأشخاص الذين لا يدركون بأن السعادة لا بد أن نستشعرها بصورة أكثر عقلانية ومنطقية فيعرضهم هذا لمواجهة الظروف الأليمة، وأكرر بأنه لا يوجد من يرغب في الحب ونيل المنال ويتلذذ بالآلام، الألم هو الألم ولكن نتيجة لظروف ما قد تكمن السعاده فيما نتحمله من كد وأسي.".b }
      it { is_expected.to be > 2.0 }
    end

    context "random bytes, language = :english" do
      let(:text) { "8\xBAfAps\x85\xB0\xA9(\x1CM\x98\xAA\x13%1\xEAl\xA3\\d2\xEC$\xD9\xB9\xE0\xB45\xEC\x18\xCEw\xD0\x1C\x93\xE5\xD3\x1C\xB0\xF8>0F\x01K\xDE\x85r\xB3)\x1F\xBB\xB0\xE1bW\xA2\xB9\xD8\xC2\xDC\xB7i=>\xC9\xFF\xA5\xA0r\x8F\x1F\xC8P\x8A\x04|q\xC3\xDB\b\x88\xE8\xF1\xBA\x83\xDBO\xD7\x8F\"m\xBF\x83\xA7\x8Cx\xE3}\xE94yP\xAEkl0cf\x03\xD4\xB3d\xFD\n\xB6$\xB2\xC5)P\xBC|\x11\xDE\xE7\xFA\r,\xF1N\x81oa\xF3\x83}\x9F\x1E\x8E\xADm}n\xABn\x96\x92\x1D\x82\xA8\x16nbj\xD2\xFE\xA9\x92\x85s\xE3YPm\xF6R#\x1F#T\xEF\xC6v!\x8A\xF25mR\t\xC4\xC6\x91@z\x8E\x1A\xF8\xD1\x1D\xE4\xC1\xC3\x9C\x86%\xB7{D\x98Qm\xB4\xFCH\x91\xA3\xF7\xAD\xD4\xE3\xE7\x86\xA66w9y$\xC3\xF6=\xBB\x17\x9Bn\xA9bC4\xA9\x7F\xD8\x14\x009\xBDH\xA7\x9Cv])\xC8\xE4\xFE\x90\xDBTGR\xE2C".b }
      it { is_expected.to be > 1.5 }
    end
  end
end

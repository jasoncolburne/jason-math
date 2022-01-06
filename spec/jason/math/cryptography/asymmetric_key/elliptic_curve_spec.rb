# frozen_string_literal: true

RSpec.describe Jason::Math::Cryptography::AsymmetricKey::EllipticCurve do
  let(:ecc) { described_class.new(curve, private_key, public_key) }

  context 'secp384r1' do
    let(:curve) { :secp384r1 }
    let(:private_key) { 11786149730743511989291261110751795001618360275527675765778924444380585057901656198033889359930256677416305144645315 }
    let(:public_key) { Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(
      1371645876915154554843485631192052158857260459410156623695815024287176399223830535294283403147841862236238511004273,
      38815024280715893002193530216205187972621951715633350484478076108800683387921196027110639697870418251402668121876105
    ) }
    let(:entropy) { 7407278997792429614718100118346226834821648880804871967998880577171127884109236798793589667645988119130728773680793 }

    let(:digest) { 'digest'.byte_string_to_integer }
    let(:signature) { Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(
      21449428499623135505784348435000890599661991798623885506423971580432277046166109693266600311822416106100166650664855,
      24797422184631820620560845656760730787347368306427043109544330552033025512140077305030035110697330124202962596483839
    ) }

    let(:clear_text) { Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(
      21337967993269287603260625663048392874508418251095735152326232336820795502397741501036006553204045565663256,
      15717239708272631507617702416745681881659309203216566197704602059588336714496356581191476673406480120673110645612824
    ) }
    let(:cipher_text) { [
      Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(
        21449428499623135505784348435000890599661991798623885506423971580432277046166109693266600311822416106100166650664855,
        32374956586558246526179322421590959182838582256120800791151376331160116955904166926634161978518004356414358574427848
      ),
      Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(
        35248162760278361182864081439737696508760611331367008330985505954804970829187313776327497655180551509583948741984314,
        38940222769447069839830150500669171914847269282833850398291938053231467200946507342956615591908128934535391876203457
      )
    ] }

    context '#sign' do
      subject { ecc.sign(digest, entropy) }
      it { is_expected.to eq(signature) }
    end

    context '#verify' do
      subject { ecc.verify(digest, signature) }

      context 'valid signature' do
        it { is_expected.to be_truthy }
      end

      context 'invalid signature' do
        let(:signature) { Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Point.new(15, 11) }
        it { is_expected.to be_falsey }
      end
    end

    context '#encrypt' do
      subject { ecc.encrypt(clear_text, entropy) }
      it { is_expected.to eq(cipher_text) }
    end

    context '#decrypt' do
      subject { ecc.decrypt(cipher_text) }
      it { is_expected.to eq(clear_text) }
    end
  end
end

# RSpec.describe Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::DiffieHellman do
#   context '#compute_secret' do
#     let(:dh) { described_class.new(curve, generator) }

#     let(:a) { 1 }
#     let(:b) { 18 }
#     let(:n) { 19 }
#     let(:curve) { Jason::Math::Cryptography::AsymmetricKey::EllipticCurve::Curve.new(a, b, n) }

#     let(:x_value) { 7 }
#     let(:generator) { curve.at(x_value).first }

#     let(:private_key_a) { 11 }
#     let(:private_key_b) { 3 }
#     let(:private_key_c) { 7 }

#     let(:public_key_a) { dh.generate_public_key(private_key_a) }
#     let(:public_key_b) { dh.generate_public_key(private_key_b) }
#     let(:public_key_c) { dh.generate_public_key(private_key_c) }

#     it 'ensures secrets match for associated keypairs' do
#       expect(dh.compute_secret(private_key_a, public_key_b)).to eq(dh.compute_secret(private_key_b, public_key_a))
#       expect(dh.compute_secret(private_key_a, public_key_c)).to eq(dh.compute_secret(private_key_c, public_key_a))
#       expect(dh.compute_secret(private_key_c, public_key_b)).to eq(dh.compute_secret(private_key_b, public_key_c))
#     end

#     it 'ensures secrets do not match for unmatched keys' do
#       expect(dh.compute_secret(private_key_a, public_key_b)).not_to eq(dh.compute_secret(private_key_a, public_key_c))
#       expect(dh.compute_secret(private_key_b, public_key_a)).not_to eq(dh.compute_secret(private_key_b, public_key_c))
#       expect(dh.compute_secret(private_key_c, public_key_a)).not_to eq(dh.compute_secret(private_key_c, public_key_b))
#     end
#   end
# end

RSpec.describe Jason::Math::Cryptography::AdvancedEncryptionStandard do
  let(:aes) { described_class.new("#{mode}_#{bits}".to_sym, key, use_openssl) }
  let(:clear_text) { "0123456789abcdefFEDCBA9876543210" }
  let(:use_openssl) { false } # toggle this to verify that test vectors are correct

  context "128-bit" do
    let(:bits) { 128 }
    let(:key) { "\x2b\x7e\x15\x16\x28\xae\xd2\xa6\xab\xf7\x15\x88\x09\xcf\x4f\x3c".b }

    context "key schedule" do
      subject { use_openssl ? key_schedule : aes.instance_variable_get(:@key_schedule) }
      let(:mode) { 'ecb' }
      let(:key_schedule) { "+~\x15\x16(\xAE\xD2\xA6\xAB\xF7\x15\x88\t\xCFO<\xA0\xFA\xFE\x17\x88T,\xB1#\xA399*lv\x05\xF2\xC2\x95\xF2z\x96\xB9CY5\x80zsY\xF6\x7F=\x80G}G\x16\xFE>\x1E#~Dmz\x88;\xEFD\xA5A\xA8R[\x7F\xB6q%;\xDB\v\xAD\x00\xD4\xD1\xC6\xF8|\x83\x9D\x87\xCA\xF2\xB8\xBC\x11\xF9\x15\xBCm\x88\xA3z\x11\v>\xFD\xDB\xF9\x86A\xCA\x00\x93\xFDNT\xF7\x0E__\xC9\xF3\x84\xA6O\xB2N\xA6\xDCO\xEA\xD2s!\xB5\x8D\xBA\xD21+\xF5`\x7F\x8D)/\xACwf\xF3\x19\xFA\xDC!(\xD1)AW\\\x00n\xD0\x14\xF9\xA8\xC9\xEE%\x89\xE1?\f\xC8\xB6c\f\xA6".b }
      it { is_expected.to eq(key_schedule) }
    end

    context "electronic codebook (ecb)" do
      let(:mode) { 'ecb' }
      let(:cipher_text) { "]\x9C\xAF\x02R\x9E\xE0\x02\xDC\xFF+\x13\xFF\x1A\x8FpQY\x84\x1A\xAA\xCC\xAA\x89\xA5\vM\x04\x14\xCD\\\x98\xA2T\xBE\x88\xE07\xDD\xD9\xD7\x9F\xB6A\x1C?\x9D\xF8".b }

      context "#decrypt" do
        subject { aes.decrypt(cipher_text) }
        it { is_expected.to eq(clear_text) }
      end

      context "#encrypt" do
        subject { aes.encrypt(clear_text) }
        it { is_expected.to eq(cipher_text) }
      end
    end

    context "cipher block chaining (cbc)" do
      let(:mode) { 'cbc' }
      let(:initialization_vector) { 'abcdefghijklmnop' }
      let(:cipher_text) { "\x85\xD5\xD1\xC0S!\x92Q\x18Q?\a1z\xA6~J\xEB\xD1C\xFC\"\x14\xD8N\x81\xB9\x1F\x82q\xD1\x1E\v\xB4\xCB\f0+\x88\x80\xEBV\x87<\xD9\xCC\xEB\x02".b }

      context "#decrypt" do
        subject { aes.decrypt(cipher_text, initialization_vector) }
        it { is_expected.to eq(clear_text) }
      end

      context "#encrypt" do
        subject { aes.encrypt(clear_text, initialization_vector) }
        it { is_expected.to eq(cipher_text) }
      end
    end

    context "cipher feedback (cfb)" do
      let(:mode) { 'cfb' }
      let(:initialization_vector) { 'abcdefghijklmnop' }
      let(:cipher_text) { "Q\x86\xEF{\xB6\xD2\xD5\x88\xFF\xED\"-_\x8E\x04\xB9\xD7\x86\xFD\x94:GC63\xEF\xFFU\xADD\xE2/".b }

      let(:smaller_clear_text) { '123456789' }
      let(:smaller_cipher_text) { "P\x85\xEE|\xB7\xD1\xD4\x87\xFE".b }

      context "#decrypt" do
        context "payload a multiple of block size" do
          subject { aes.decrypt(cipher_text, initialization_vector) }
          it { is_expected.to eq(clear_text) }
        end

        context "9 byte payload" do
          subject { aes.decrypt(smaller_cipher_text, initialization_vector) }
          it { is_expected.to eq(smaller_clear_text) }
        end
      end

      context "#encrypt" do
        context "payload a multiple of block size" do
          subject { aes.encrypt(clear_text, initialization_vector) }
          it { is_expected.to eq(cipher_text) }
        end

        context "9 byte payload" do
          subject { aes.encrypt(smaller_clear_text, initialization_vector) }
          it { is_expected.to eq(smaller_cipher_text) }
        end
      end
    end
  end

  context "192-bit" do
    let(:bits) { 192 }
    let(:key) { "\x8e\x73\xb0\xf7\xda\x0e\x64\x52\xc8\x10\xf3\x2b\x80\x90\x79\xe5\x62\xf8\xea\xd2\x52\x2c\x6b\x7b".b }

    context "key schedule" do
      subject { use_openssl ? key_schedule : aes.instance_variable_get(:@key_schedule) }
      let(:mode) { 'ecb' }
      let(:key_schedule) { "\x8Es\xB0\xF7\xDA\x0EdR\xC8\x10\xF3+\x80\x90y\xE5b\xF8\xEA\xD2R,k{\xFE\f\x91\xF7$\x02\xF5\xA5\xEC\x12\x06\x8El\x82\x7Fk\x0Ez\x95\xB9\\V\xFE\xC2M\xB7\xB4\xBDi\xB5A\x18\x85\xA7G\x96\xE9%8\xFD\xE7_\xADD\xBB\tS\x86HZ\xF0W!\xEF\xB1O\xA4H\xF6\xD9Mm\xCE$\xAA2c`\x11;0\xE6\xA2^~\xD5\x83\xB1\xCF\x9A'\xF99Cj\x94\xF7g\xC0\xA6\x94\a\xD1\x9D\xA4\xE1\xEC\x17\x86\xEBo\xA6IqH_p2\"\xCB\x87U\xE2m\x13R3\xF0\xB7\xB3@\xBE\xEB(/\x18\xA2YgG\xD2kE\x8CU>\xA7\xE1Fl\x94\x11\xF1\xDF\x82\x1Fu\n\xAD\a\xD7S\xCA@\x058\x8F\xCCP\x06(-\x16j\xBC<\xE7\xB5\xE9\x8B\xA0oD\x8Cw<\x8E\xCCr\x04\x01\x00\"\x02".b }
      it { is_expected.to eq(key_schedule) }
    end

    context "electronic codebook (ecb)" do
      let(:mode) { 'ecb' }
      let(:cipher_text) { "\xDD\xA1\xB5Y\x96\xE8B\xCC\f\xB4\x8B\xDC\xF3\xAE\xD6\t!M\x99\xD4/W\x13\xAFM\xB0]\xA2\x14\v\xD3\x05\xDA\xA0\xAF\aK\xD8\b<\x8A2\xD4\xFCV<U\xCC".b }

      context "#decrypt" do
        subject { aes.decrypt(cipher_text) }
        it { is_expected.to eq(clear_text) }
      end

      context "#encrypt" do
        subject { aes.encrypt(clear_text) }
        it { is_expected.to eq(cipher_text) }
      end
    end

    context "cipher block chaining (cbc)" do
      let(:mode) { 'cbc' }
      let(:initialization_vector) { 'abcdefghijklmnop' }
      let(:cipher_text) { "\xA1\x0E\xE2\xBC\xC0\x9D\x82fr\xC4}j\xFF\xC0\xA1\xAD\xBAak\xA1a\x81\xED\xC7\x9C\xC8(P\xD6\x19\x1D\xE3[\x8E\x8F\x05\x16\xCD\x16\x9Ez3\xF4B)\xF3\xEB&".b }

      context "#decrypt" do
        subject { aes.decrypt(cipher_text, initialization_vector) }
        it { is_expected.to eq(clear_text) }
      end

      context "#encrypt" do
        subject { aes.encrypt(clear_text, initialization_vector) }
        it { is_expected.to eq(cipher_text) }
      end
    end

    context "cipher feedback (cfb)" do
      let(:mode) { 'cfb' }
      let(:initialization_vector) { 'abcdefghijklmnop' }
      let(:cipher_text) { "\x88\xB0\xDFS\x97\xC3\xEF\xEBbD\x02&4}SkwK@1\xE9\x823\x1E'\xC2riW\xA5|\xCD".b }

      let(:smaller_clear_text) { '123456789' }
      let(:smaller_cipher_text) { "\x89\xB3\xDET\x96\xC0\xEE\xE4c".b }

      context "#decrypt" do
        context "payload a multiple of block size" do
          subject { aes.decrypt(cipher_text, initialization_vector) }
          it { is_expected.to eq(clear_text) }
        end

        context "9 byte payload" do
          subject { aes.decrypt(smaller_cipher_text, initialization_vector) }
          it { is_expected.to eq(smaller_clear_text) }
        end
      end

      context "#encrypt" do
        context "payload a multiple of block size" do
          subject { aes.encrypt(clear_text, initialization_vector) }
          it { is_expected.to eq(cipher_text) }
        end

        context "9 byte payload" do
          subject { aes.encrypt(smaller_clear_text, initialization_vector) }
          it { is_expected.to eq(smaller_cipher_text) }
        end
      end
    end
  end

  context "256-bit" do
    let(:bits) { 256 }
    let(:key) { "\x60\x3d\xeb\x10\x15\xca\x71\xbe\x2b\x73\xae\xf0\x85\x7d\x77\x81\x1f\x35\x2c\x07\x3b\x61\x08\xd7\x2d\x98\x10\xa3\x09\x14\xdf\xf4".b }

    context "key schedule" do
      subject { use_openssl ? key_schedule : aes.instance_variable_get(:@key_schedule) }
      let(:mode) { 'ecb' }
      let(:key_schedule) { "`=\xEB\x10\x15\xCAq\xBE+s\xAE\xF0\x85}w\x81\x1F5,\a;a\b\xD7-\x98\x10\xA3\t\x14\xDF\xF4\x9B\xA3T\x11\x8Ei%\xAF\xA5\x1A\x8B_ g\xFC\xDE\xA8\xB0\x9C\x1A\x93\xD1\x94\xCD\xBEI\x84n\xB7][\x9A\xD5\x9A\xEC\xB8[\xF3\xC9\x17\xFE\xE9BH\xDE\x8E\xBE\x96\xB5\xA92\x8A&x\xA6G\x981\")/ly\xB3\x81,\x81\xAD\xDA\xDFH\xBA$6\n\xF2\xFA\xB8\xB4d\x98\xC5\xBF\xC9\xBE\xBD\x19\x8E&\x8C;\xA7\t\xE0B\x14h\x00{\xAC\xB2\xDF3\x16\x96\xE99\xE4lQ\x8D\x80\xC8\x14\xE2\x04v\xA9\xFB\x8AP%\xC0-Y\xC5\x829\xDE\x13igl\xCCZq\xFA%c\x95\x96t\xEE\x15X\x86\xCA]./1\xD7~\n\xF1\xFA'\xCFs\xC3t\x9CG\xAB\x18P\x1D\xDA\xE2u~Ot\x01\x90Z\xCA\xFA\xAA\xE3\xE4\xD5\x9B4\x9A\xDFj\xCE\xBD\x10\x19\r\xFEH\x90\xD1\xE6\x18\x8D\v\x04m\xF3Dplc\x1E".b }
      it { is_expected.to eq(key_schedule) }
    end

    context "electronic codebook (ecb)" do
      let(:mode) { 'ecb' }
      let(:cipher_text) { "\xC6\xD9\xB4W\xEB\xCF?\vZ\xEFg\xD2\x93\bX\x04{7\x91U\xA9\x8BB\xE7\xE5v\xD3\xEA\xDE\x8F\x1E\x1FLE\xDF\xB3\xB3\xB4\x84\xEC5\xB0Q-\xC8\xC1\xC4\xD6".b }

      context "#decrypt" do
        subject { aes.decrypt(cipher_text) }
        it { is_expected.to eq(clear_text) }
      end

      context "#encrypt" do
        subject { aes.encrypt(clear_text) }
        it { is_expected.to eq(cipher_text) }
      end
    end

    context "cipher block chaining (cbc)" do
      let(:mode) { 'cbc' }
      let(:initialization_vector) { 'abcdefghijklmnop' }
      let(:cipher_text) { "^\xED\x80Cu3\xE7\xEF\xA00+\xE8k\xB6\"\xF5\xE9(\xDE\x043\x8C\x06\x10\x9E\xE9\vcX!\x01\xB2\xB0/3T\x8D\xF9\xA4S\xA1Bw\x05\x14\xFE!\xFC".b }

      context "#decrypt" do
        subject { aes.decrypt(cipher_text, initialization_vector) }
        it { is_expected.to eq(clear_text) }
      end

      context "#encrypt" do
        subject { aes.encrypt(clear_text, initialization_vector) }
        it { is_expected.to eq(cipher_text) }
      end
    end

    context "cipher feedback (cfb)" do
      let(:mode) { 'cfb' }
      let(:initialization_vector) { 'abcdefghijklmnop' }
      let(:cipher_text) { "\\\xD65\xB0\x9F\xF8\v\xDE\xE0\x00\xA0\xEDh\xD8uj\\\x88_9\xC3\x196\xABT\xCD\xF8:\xFB?\xA7\x13".b }

      let(:smaller_clear_text) { '123456789' }
      let(:smaller_cipher_text) { "]\xD54\xB7\x9E\xFB\n\xD1\xE1".b }

      context "#decrypt" do
        context "payload a multiple of block size" do
          subject { aes.decrypt(cipher_text, initialization_vector) }
          it { is_expected.to eq(clear_text) }
        end

        context "9 byte payload" do
          subject { aes.decrypt(smaller_cipher_text, initialization_vector) }
          it { is_expected.to eq(smaller_clear_text) }
        end
      end

      context "#encrypt" do
        context "payload a multiple of block size" do
          subject { aes.encrypt(clear_text, initialization_vector) }
          it { is_expected.to eq(cipher_text) }
        end

        context "9 byte payload" do
          subject { aes.encrypt(smaller_clear_text, initialization_vector) }
          it { is_expected.to eq(smaller_cipher_text) }
        end
      end
    end
  end
end

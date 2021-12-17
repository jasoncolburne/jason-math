# frozen_string_literal: true

require 'set'

RSpec.describe Jason::Math::NumberTheory do
  context '#primes' do
    subject { described_class.primes(count) }

    context 'first 10' do
      let(:count) { 10 }
      it { is_expected.to eq([2, 3, 5, 7, 11, 13, 17, 19, 23, 29]) }
    end
  end

  context '#primes_below' do
    subject { described_class.primes_below(limit) }

    context 'below 29' do
      let(:limit) { 29 }
      it { is_expected.to eq([2, 3, 5, 7, 11, 13, 17, 19, 23]) }
    end
  end

  context '#factors' do
    subject { described_class.factors(n) }

    context "of #{2 * 2 * 2 * 3 * 5 * 5 * 7 * 7 * 7 * 11 * 13 * 17 * 17 * 19}" do
      let(:n) { 2 * 2 * 2 * 3 * 5 * 5 * 7 * 7 * 7 * 11 * 13 * 17 * 17 * 19 }
      it { is_expected.to eq({ 2 => 3, 3 => 1, 5 => 2, 7 => 3, 11 => 1, 13 => 1, 17 => 2, 19 => 1 }) }
    end

    context 'of 5' do
      let(:n) { 5 }
      it { is_expected.to eq({ 5 => 1 }) }
    end
  end

  context '#prime' do
    subject { described_class.prime(offset) }

    context '1st' do
      let(:offset) { 1 }
      it { is_expected.to eq(2) }
    end

    context '100000th' do
      let(:offset) { 100_000 }
      it { is_expected.to eq(1_299_709) }
    end
  end

  context '#prime?' do
    subject { described_class.prime?(n) }

    context '2' do
      let(:n) { 2 }
      it { is_expected.to be_truthy }
    end

    context '4' do
      let(:n) { 4 }
      it { is_expected.to be_falsey }
    end

    context '17' do
      let(:n) { 17 }
      it { is_expected.to be_truthy }
    end

    context '25' do
      let(:n) { 25 }
      it { is_expected.to be_falsey }
    end

    context '1299709 (100000th prime)' do
      let(:n) { 1_299_709 }
      it { is_expected.to be_truthy }
    end

    context '1299709 * 1299721 (100000th and 100001st primes)' do
      let(:n) { 1_299_709 * 1_299_721 }
      it { is_expected.to be_falsey }
    end

    context '116136133237524628623079973436761666157812135802554422133884399716278215827708188540430994158743163224360474004390260851035079396569070805436204141716645377206469931168305351122258807934047024235765278566582937247825531441295648260124631056178986340098086793666788683120626019654875802245983332214723863553333, below 1299709' do
      subject { described_class.prime?(n, below) }
      let(:n) do
        116_136_133_237_524_628_623_079_973_436_761_666_157_812_135_802_554_422_133_884_399_716_278_215_827_708_188_540_430_994_158_743_163_224_360_474_004_390_260_851_035_079_396_569_070_805_436_204_141_716_645_377_206_469_931_168_305_351_122_258_807_934_047_024_235_765_278_566_582_937_247_825_531_441_295_648_260_124_631_056_178_986_340_098_086_793_666_788_683_120_626_019_654_875_802_245_983_332_214_723_863_553_333
      end
      let(:below) { 1_299_709 }
      it { is_expected.to be_truthy }
    end

    context '116136133237524628623079973436761666157812135802554422133884399716278215827708188540430994158743163224360474004390260851035079396569070805436204141716645377206469931168305351122258807934047024235765278566582937247825531441295648260124631056178986340098086793666788683120626019654875802245983332214723863553333 * 149266604066765214257465899845052595936980433085281120472438633560109109845062080813195674897136525949840184965312505298869948722977649469023084361550412989486060207917580540454081140587353862234445577520476872543676486167892443872308705026778461121261224322495328346630383486386663628878772838449087770123303, below 1299709' do
      subject { described_class.prime?(n, below) }
      let(:n) do
        116_136_133_237_524_628_623_079_973_436_761_666_157_812_135_802_554_422_133_884_399_716_278_215_827_708_188_540_430_994_158_743_163_224_360_474_004_390_260_851_035_079_396_569_070_805_436_204_141_716_645_377_206_469_931_168_305_351_122_258_807_934_047_024_235_765_278_566_582_937_247_825_531_441_295_648_260_124_631_056_178_986_340_098_086_793_666_788_683_120_626_019_654_875_802_245_983_332_214_723_863_553_333 * 149_266_604_066_765_214_257_465_899_845_052_595_936_980_433_085_281_120_472_438_633_560_109_109_845_062_080_813_195_674_897_136_525_949_840_184_965_312_505_298_869_948_722_977_649_469_023_084_361_550_412_989_486_060_207_917_580_540_454_081_140_587_353_862_234_445_577_520_476_872_543_676_486_167_892_443_872_308_705_026_778_461_121_261_224_322_495_328_346_630_383_486_386_663_628_878_772_838_449_087_770_123_303
      end
      let(:below) { 1_299_709 }
      it { is_expected.to be_truthy }
    end
  end

  context '#prime_by_weak_fermat?' do
    subject { described_class.prime_by_weak_fermat?(n) }

    context '116136133237524628623079973436761666157812135802554422133884399716278215827708188540430994158743163224360474004390260851035079396569070805436204141716645377206469931168305351122258807934047024235765278566582937247825531441295648260124631056178986340098086793666788683120626019654875802245983332214723863553333' do
      let(:n) do
        116_136_133_237_524_628_623_079_973_436_761_666_157_812_135_802_554_422_133_884_399_716_278_215_827_708_188_540_430_994_158_743_163_224_360_474_004_390_260_851_035_079_396_569_070_805_436_204_141_716_645_377_206_469_931_168_305_351_122_258_807_934_047_024_235_765_278_566_582_937_247_825_531_441_295_648_260_124_631_056_178_986_340_098_086_793_666_788_683_120_626_019_654_875_802_245_983_332_214_723_863_553_333
      end
      it { is_expected.to be_truthy }
    end

    context '116136133237524628623079973436761666157812135802554422133884399716278215827708188540430994158743163224360474004390260851035079396569070805436204141716645377206469931168305351122258807934047024235765278566582937247825531441295648260124631056178986340098086793666788683120626019654875802245983332214723863553333 * 149266604066765214257465899845052595936980433085281120472438633560109109845062080813195674897136525949840184965312505298869948722977649469023084361550412989486060207917580540454081140587353862234445577520476872543676486167892443872308705026778461121261224322495328346630383486386663628878772838449087770123303' do
      let(:n) do
        116_136_133_237_524_628_623_079_973_436_761_666_157_812_135_802_554_422_133_884_399_716_278_215_827_708_188_540_430_994_158_743_163_224_360_474_004_390_260_851_035_079_396_569_070_805_436_204_141_716_645_377_206_469_931_168_305_351_122_258_807_934_047_024_235_765_278_566_582_937_247_825_531_441_295_648_260_124_631_056_178_986_340_098_086_793_666_788_683_120_626_019_654_875_802_245_983_332_214_723_863_553_333 * 149_266_604_066_765_214_257_465_899_845_052_595_936_980_433_085_281_120_472_438_633_560_109_109_845_062_080_813_195_674_897_136_525_949_840_184_965_312_505_298_869_948_722_977_649_469_023_084_361_550_412_989_486_060_207_917_580_540_454_081_140_587_353_862_234_445_577_520_476_872_543_676_486_167_892_443_872_308_705_026_778_461_121_261_224_322_495_328_346_630_383_486_386_663_628_878_772_838_449_087_770_123_303
      end
      it { is_expected.to be_falsey }
    end
  end

  context '#prime_by_miller_rabin?' do
    subject { described_class.prime_by_miller_rabin?(n) }

    context '116136133237524628623079973436761666157812135802554422133884399716278215827708188540430994158743163224360474004390260851035079396569070805436204141716645377206469931168305351122258807934047024235765278566582937247825531441295648260124631056178986340098086793666788683120626019654875802245983332214723863553333' do
      let(:n) do
        116_136_133_237_524_628_623_079_973_436_761_666_157_812_135_802_554_422_133_884_399_716_278_215_827_708_188_540_430_994_158_743_163_224_360_474_004_390_260_851_035_079_396_569_070_805_436_204_141_716_645_377_206_469_931_168_305_351_122_258_807_934_047_024_235_765_278_566_582_937_247_825_531_441_295_648_260_124_631_056_178_986_340_098_086_793_666_788_683_120_626_019_654_875_802_245_983_332_214_723_863_553_333
      end
      it { is_expected.to be_truthy }
    end

    context '116136133237524628623079973436761666157812135802554422133884399716278215827708188540430994158743163224360474004390260851035079396569070805436204141716645377206469931168305351122258807934047024235765278566582937247825531441295648260124631056178986340098086793666788683120626019654875802245983332214723863553333 * 149266604066765214257465899845052595936980433085281120472438633560109109845062080813195674897136525949840184965312505298869948722977649469023084361550412989486060207917580540454081140587353862234445577520476872543676486167892443872308705026778461121261224322495328346630383486386663628878772838449087770123303' do
      let(:n) do
        116_136_133_237_524_628_623_079_973_436_761_666_157_812_135_802_554_422_133_884_399_716_278_215_827_708_188_540_430_994_158_743_163_224_360_474_004_390_260_851_035_079_396_569_070_805_436_204_141_716_645_377_206_469_931_168_305_351_122_258_807_934_047_024_235_765_278_566_582_937_247_825_531_441_295_648_260_124_631_056_178_986_340_098_086_793_666_788_683_120_626_019_654_875_802_245_983_332_214_723_863_553_333 * 149_266_604_066_765_214_257_465_899_845_052_595_936_980_433_085_281_120_472_438_633_560_109_109_845_062_080_813_195_674_897_136_525_949_840_184_965_312_505_298_869_948_722_977_649_469_023_084_361_550_412_989_486_060_207_917_580_540_454_081_140_587_353_862_234_445_577_520_476_872_543_676_486_167_892_443_872_308_705_026_778_461_121_261_224_322_495_328_346_630_383_486_386_663_628_878_772_838_449_087_770_123_303
      end
      it { is_expected.to be_falsey }
    end
  end

  context '#probably_prime?' do
    subject { described_class.probably_prime?(n) }

    context '116136133237524628623079973436761666157812135802554422133884399716278215827708188540430994158743163224360474004390260851035079396569070805436204141716645377206469931168305351122258807934047024235765278566582937247825531441295648260124631056178986340098086793666788683120626019654875802245983332214723863553333' do
      let(:n) do
        116_136_133_237_524_628_623_079_973_436_761_666_157_812_135_802_554_422_133_884_399_716_278_215_827_708_188_540_430_994_158_743_163_224_360_474_004_390_260_851_035_079_396_569_070_805_436_204_141_716_645_377_206_469_931_168_305_351_122_258_807_934_047_024_235_765_278_566_582_937_247_825_531_441_295_648_260_124_631_056_178_986_340_098_086_793_666_788_683_120_626_019_654_875_802_245_983_332_214_723_863_553_333
      end
      it { is_expected.to be_truthy }
    end

    context '116136133237524628623079973436761666157812135802554422133884399716278215827708188540430994158743163224360474004390260851035079396569070805436204141716645377206469931168305351122258807934047024235765278566582937247825531441295648260124631056178986340098086793666788683120626019654875802245983332214723863553333 * 149266604066765214257465899845052595936980433085281120472438633560109109845062080813195674897136525949840184965312505298869948722977649469023084361550412989486060207917580540454081140587353862234445577520476872543676486167892443872308705026778461121261224322495328346630383486386663628878772838449087770123303' do
      let(:n) do
        116_136_133_237_524_628_623_079_973_436_761_666_157_812_135_802_554_422_133_884_399_716_278_215_827_708_188_540_430_994_158_743_163_224_360_474_004_390_260_851_035_079_396_569_070_805_436_204_141_716_645_377_206_469_931_168_305_351_122_258_807_934_047_024_235_765_278_566_582_937_247_825_531_441_295_648_260_124_631_056_178_986_340_098_086_793_666_788_683_120_626_019_654_875_802_245_983_332_214_723_863_553_333 * 149_266_604_066_765_214_257_465_899_845_052_595_936_980_433_085_281_120_472_438_633_560_109_109_845_062_080_813_195_674_897_136_525_949_840_184_965_312_505_298_869_948_722_977_649_469_023_084_361_550_412_989_486_060_207_917_580_540_454_081_140_587_353_862_234_445_577_520_476_872_543_676_486_167_892_443_872_308_705_026_778_461_121_261_224_322_495_328_346_630_383_486_386_663_628_878_772_838_449_087_770_123_303
      end
      it { is_expected.to be_falsey }
    end
  end

  context '#divisors' do
    subject { described_class.divisors(n) }

    context 'of 24' do
      let(:n) { 24 }
      it { is_expected.to eq([1, 2, 4, 8, 3, 6, 12, 24]) }
    end

    # this is a performance test, old implementation would take seconds
    context 'of 2**24' do
      let(:n) { 2**24 }
      it {
        is_expected.to eq([1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16_384, 32_768, 65_536, 131_072,
                           262_144, 524_288, 1_048_576, 2_097_152, 4_194_304, 8_388_608, 16_777_216])
      }
    end

    context 'of 17' do
      let(:n) { 17 }
      it { is_expected.to eq([1, 17]) }
    end
  end

  context '#proper_divisors' do
    subject { described_class.proper_divisors(n) }

    context 'of 24' do
      let(:n) { 24 }
      it { is_expected.to eq([1, 2, 4, 8, 3, 6, 12]) }
    end

    context 'of 17' do
      let(:n) { 17 }
      it { is_expected.to eq([1]) }
    end
  end

  context '#totient' do
    subject { described_class.totient(n) }

    context 'of 1299709' do
      let(:n) { 1_299_709 }
      it { is_expected.to eq(1_299_708) }
    end

    context 'of 10' do
      let(:n) { 10 }
      it { is_expected.to eq(4) }
    end
  end

  context '#co_prime?' do
    subject { described_class.co_prime?(numbers) }

    context 'for [2, 3, 5, 7, 11, 13, 17, 19]' do
      let(:numbers) { [2, 3, 5, 7, 11, 13, 17, 19] }
      it { is_expected.to be_truthy }
    end

    context 'for [2, 3, 5, 7, 9, 11, 13, 17, 19]' do
      let(:numbers) { [2, 3, 5, 7, 9, 11, 13, 17, 19] }
      it { is_expected.to be_falsey }
    end

    context 'for [2, 26]' do
      # this is a regression test - i experimented with only going up to the root of the
      # second maximum number and it broke things.
      let(:numbers) { [2, 26] }
      it { is_expected.to be_falsey }
    end

    context 'for [2, 32193213281156929]' do
      # this tests that we return early even if prime < root_max_n if we have resolved
      # all but one number to 1. if this test runs super slowly, you fucked up.
      let(:numbers) { [2, 32_193_213_281_156_929] }
      it { is_expected.to be_truthy }
    end

    context 'for [1, 4, 5]' do
      # 1 is coprime with everything
      let(:numbers) { [1, 4, 5] }
      it { is_expected.to be_truthy }
    end
  end

  context '#gcd' do
    subject { described_class.gcd(x, y) }

    context 'for 12, 21' do
      let(:x) { 12 }
      let(:y) { 21 }
      it { is_expected.to eq(3) }
    end

    context 'for 12, 35' do
      let(:x) { 12 }
      let(:y) { 35 }
      it { is_expected.to eq(1) }
    end

    context 'for 26, 52' do
      let(:x) { 26 }
      let(:y) { 52 }
      it { is_expected.to eq(26) }
    end

    context 'for 100, 100' do
      let(:x) { 100 }
      let(:y) { 100 }
      it { is_expected.to eq(100) }
    end
  end

  context '#lcm' do
    subject { described_class.lcm(x, y) }

    context 'for 12, 21' do
      let(:x) { 12 }
      let(:y) { 21 }
      it { is_expected.to eq(84) }
    end

    context 'for 12, 35' do
      let(:x) { 12 }
      let(:y) { 35 }
      it { is_expected.to eq(420) }
    end

    context 'for 26, 52' do
      let(:x) { 26 }
      let(:y) { 52 }
      it { is_expected.to eq(52) }
    end

    context 'for 100, 100' do
      let(:x) { 100 }
      let(:y) { 100 }
      it { is_expected.to eq(100) }
    end
  end

  context '#chinese_remainder_theorem' do
    subject { described_class.chinese_remainder_theorem(values_by_moduli) }

    context 'where x is congruent to 3 (mod 5), 5 (mod 7), 4 (mod 9)' do
      let(:values_by_moduli) { { 5 => 3, 7 => 5, 9 => 4 } }
      it { is_expected.to eq(103) }
    end
  end

  context '#polygonal_number' do
    subject { described_class.polygonal_number(n, offset) }

    context '10th triangular number' do
      let(:n) { 3 }
      let(:offset) { 10 }
      it { is_expected.to eq(55) }
    end
  end

  context '#perfect?' do
    subject { described_class.perfect?(n) }

    context '28' do
      let(:n) { 28 }
      it { is_expected.to be_truthy }
    end

    context '12' do
      let(:n) { 12 }
      it { is_expected.to be_falsey }
    end

    context '2' do
      let(:n) { 2 }
      it { is_expected.to be_falsey }
    end
  end

  context '#deficient?' do
    subject { described_class.deficient?(n) }

    context '28' do
      let(:n) { 28 }
      it { is_expected.to be_falsey }
    end

    context '12' do
      let(:n) { 12 }
      it { is_expected.to be_falsey }
    end

    context '2' do
      let(:n) { 2 }
      it { is_expected.to be_truthy }
    end
  end

  context '#abundant?' do
    subject { described_class.abundant?(n) }

    context '28' do
      let(:n) { 28 }
      it { is_expected.to be_falsey }
    end

    context '12' do
      let(:n) { 12 }
      it { is_expected.to be_truthy }
    end

    context '2' do
      let(:n) { 2 }
      it { is_expected.to be_falsey }
    end
  end

  context '#palindrome?' do
    subject { described_class.palindrome?(n) }

    context '71317' do
      let(:n) { 71_317 }
      it { is_expected.to be_truthy }
    end

    context '24566' do
      let(:n) { 24_566 }
      it { is_expected.to be_falsey }
    end

    context '585, base 2' do
      subject { described_class.palindrome?(n, base) }
      let(:n) { 585 }
      let(:base) { 2 }
      it { is_expected.to be_truthy }
    end
  end

  context '#lychrel?' do
    subject { described_class.lychrel?(n, depth) }

    context '47' do
      let(:n) { 47 }
      let(:depth) { 1 }
      it { is_expected.to be_falsey }
    end

    context '349, depth 3' do
      let(:n) { 349 }
      let(:depth) { 3 }
      it { is_expected.to be_falsey }
    end

    context '349, depth 2' do
      let(:n) { 349 }
      let(:depth) { 2 }
      it { is_expected.to be_truthy }
    end

    context '196, depth 1000' do
      let(:n) { 196 }
      let(:depth) { 1000 }
      it { is_expected.to be_truthy }
    end
  end

  context '#pandigital?' do
    subject { described_class.pandigital?(argument) }

    context '42531' do
      let(:argument) { 42_531 }
      it { is_expected.to be_truthy }
    end

    context '425314' do
      let(:argument) { 425_314 }
      it { is_expected.to be_falsey }
    end

    context '42631' do
      let(:argument) { 42_631 }
      it { is_expected.to be_falsey }
    end

    context '[14, 52, 3687]' do
      let(:argument) { [14, 52, 3687] }
      it { is_expected.to be_truthy }
    end

    context '[14, 52, 3687, 0]' do
      let(:argument) { [14, 52, 3687, 0] }
      it { is_expected.to be_falsey }
    end

    context '[1]' do
      let(:argument) { [1] }
      it { is_expected.to be_truthy }
    end

    # important test
    context '[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]' do
      let(:argument) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }
      it { is_expected.to be_falsey }
    end

    context '2013, initial = 0' do
      subject { described_class.pandigital?(argument, initial) }
      let(:argument) { 2013 }
      let(:initial) { 0 }
      it { is_expected.to be_truthy }
    end

    context '321, initial = 0' do
      subject { described_class.pandigital?(argument, initial) }
      let(:argument) { 321 }
      let(:initial) { 0 }
      it { is_expected.to be_falsey }
    end

    context '2534, initial = 2' do
      subject { described_class.pandigital?(argument, initial) }
      let(:argument) { 2534 }
      let(:initial) { 2 }
      it { is_expected.to be_truthy }
    end
  end

  context '#reverse' do
    subject { described_class.reverse(n) }

    context '9294745263867334858' do
      let(:n) { 9_294_745_263_867_334_858 }
      it { is_expected.to eq(8_584_337_683_625_474_929) }
    end
  end
end

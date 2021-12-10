require 'jason/math/cryptography/elliptic_curve'
require 'jason/math/cryptography/exclusive_or'

module Jason
  module Math
    module Cryptography
      def self.hamming_distance(a, b)
        raise "Cannot compute hamming distance if lengths differ" unless a.length == b.length
        Jason::Math::Utility.xor(a, b).unpack('B*').first.count('1')
      end
    end
  end
end

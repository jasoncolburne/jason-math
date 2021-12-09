require 'jason/math/cryptography/elliptic_curve'

module Jason
  module Math
    module Cryptography
      def self.xor_cipher(data, key)
        key_characters = key.chars
        data.chars.map do |character|
          result = Jason::Math::Utility.xor(character, key_characters[0])
          key_characters << key_characters.shift
          result
        end.join
      end

      def self.hamming_distance(a, b)
        raise "Cannot compute hamming distance if lengths differ" unless a.length == b.length
        Jason::Math::Utility.xor(a, b).unpack('B*').first.count('1')
      end
    end
  end
end

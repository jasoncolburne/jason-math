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
    end
  end
end
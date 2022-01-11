# frozen_string_literal: true

require 'jason/math/cryptography/pseudo_random_number_generation/p_r_n_g_byte_stream'
require 'jason/math/cryptography/p_k_c_s_7'
require 'jason/math/cryptography/symmetric_key/advanced_encryption_standard'
require 'jason/math/cryptography/pseudo_random_number_generation/mersenne_twister_19937'
require 'jason/math/cryptography/symmetric_key/exclusive_or_cipher'
require 'jason/math/cryptography/cipher'
require 'jason/math/cryptography/asymmetric_key/elliptic_curve'
require 'jason/math/cryptography/asymmetric_key/rivest_shamir_adleman'
require 'jason/math/cryptography/digest/blake'
require 'jason/math/cryptography/key_stretching/argon_2'
require 'jason/math/cryptography/digest/message_digest'
require 'jason/math/cryptography/digest/secure_hash_algorithm'
require 'jason/math/cryptography/digest'
require 'jason/math/cryptography/asymmetric_key/digital_signature_algorithm'
require 'jason/math/cryptography/message_authentication/hashed_message_authentication_code'
require 'jason/math/cryptography/key_agreement/diffie_hellman'

module Jason
  module Math
    # Cryptography
    module Cryptography
      def self.hamming_distance(a, b)
        raise 'Cannot compute hamming distance if lengths differ' unless a.length == b.length

        Utility.xor(a, b).unpack1('B*').count('1')
      end

      def self.secure_compare(byte_string_to_test, known_byte_string)
        result = true

        byte_string_to_test.b.each_char.with_index do |char, index|
          result &&= (char == known_byte_string.b[index])
        end

        result
      end
    end
  end
end

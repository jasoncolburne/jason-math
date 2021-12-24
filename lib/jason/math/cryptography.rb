# frozen_string_literal: true

require 'jason/math/cryptography/p_r_n_g_byte_stream'
require 'jason/math/cryptography/p_k_c_s_7'
require 'jason/math/cryptography/advanced_encryption_standard'
require 'jason/math/cryptography/mersenne_twister_19937'
require 'jason/math/cryptography/exclusive_or_cipher'
require 'jason/math/cryptography/cipher'
require 'jason/math/cryptography/elliptic_curve'
require 'jason/math/cryptography/secure_hash_algorithm'
require 'jason/math/cryptography/message_digest'
require 'jason/math/cryptography/digest'

module Jason
  module Math
    # Cryptography
    module Cryptography
      def self.hamming_distance(a, b)
        raise 'Cannot compute hamming distance if lengths differ' unless a.length == b.length

        Utility.xor(a, b).unpack1('B*').count('1')
      end
    end
  end
end

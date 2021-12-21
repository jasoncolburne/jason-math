# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      # PKCS7 padding
      class PKCS7
        def self.pad(data, block_size)
          length = data.length
          total_length = (length / block_size + 1) * block_size
          padding = total_length - length
          (data + ([padding] * padding).pack('C*')).b
        end

        def self.pad_block(data, block_size)
          padding = block_size - data.length
          padding.zero? ? data : (data + ([padding] * padding).pack('C*')).b
        end

        def self.strip(data, block_size)
          padding = validate(data, block_size)
          data[0..(-padding - 1)]
        end

        def self.validate(data, block_size)
          raise 'Data length must be a multiple of block_size' unless (data.length % block_size).zero?

          padding = data[-1].ord

          raise 'Invalid padding' if padding > block_size || padding.zero?
          raise 'Invalid padding' unless data[-padding..] == ([padding] * padding).pack('C*')

          padding
        end
      end
    end
  end
end

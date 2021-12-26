# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      # An abstraction of digests
      class Digest
        # rubocop:disable Naming/VariableNumber
        ALGORITHMS = {
          blake2b: { class: Blake, mode: :'2b' }.freeze,
          md4: { class: MessageDigest, mode: :'4' }.freeze,
          sha_1: { class: SecureHashAlgorithm, mode: :'1' }.freeze,
          sha_224: { class: SecureHashAlgorithm, mode: :'224' }.freeze,
          sha_256: { class: SecureHashAlgorithm, mode: :'256' }.freeze,
          sha_384: { class: SecureHashAlgorithm, mode: :'384' }.freeze,
          sha_512: { class: SecureHashAlgorithm, mode: :'512' }.freeze,
          sha_512_224: { class: SecureHashAlgorithm, mode: :'512_224' }.freeze,
          sha_512_256: { class: SecureHashAlgorithm, mode: :'512_256' }.freeze
        }.freeze
        # rubocop:enable Naming/VariableNumber

        def initialize(algorithm)
          raise 'Unsupported algorithm' unless ALGORITHMS.keys.include?(algorithm)

          details = ALGORITHMS[algorithm]
          @digest = details[:class].new(details[:mode])
        end

        def digest(message = '')
          @digest.digest(message)
        end

        def <<(message)
          @digest.update(message)
        end

        def update(message)
          @digest.update(message)
        end

        def state=(state)
          @digest.state = state
        end

        def cumulative_length=(length)
          @digest.cumulative_length = length
        end

        def self.pad(message, byte_order = :network, length = nil, block_size = 64)
          padded_message = message + "\x80".b
          overflow_length = (padded_message.length + block_size / 8) % block_size
          padding_length = (block_size - overflow_length) % block_size

          padded_message += "\x00".b * padding_length
          packing_string = byte_order == :network ? 'Q>*' : 'Q<*'
          length_value = (length || message.length) << 3
          to_pack = []
          mask = 0xffffffffffffffff
          (block_size / 64).times do
            to_pack.unshift(length_value & mask)
            length_value >>= 64
          end

          padded_message + to_pack.pack(packing_string)
        end
      end
    end
  end
end

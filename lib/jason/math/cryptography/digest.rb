# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      # An abstraction of digests
      class Digest
        # rubocop:disable Naming/VariableNumber
        ALGORITHMS = {
          sha_1: { class: SecureHashAlgorithm, mode: :'1' }.freeze
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

        def self.merkle_damgard_pad(message, length = nil, block_size = 64)
          padded_message = message + "\x80".b
          overflow_length = (padded_message.length + 8) % block_size
          padding_length = (block_size - overflow_length) % block_size

          padded_message += "\x00".b * padding_length
          padded_message + [(length || message.length) << 3].pack('Q>*')
        end
      end
    end
  end
end

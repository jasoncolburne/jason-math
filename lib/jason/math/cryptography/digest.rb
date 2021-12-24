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
      end
    end
  end
end

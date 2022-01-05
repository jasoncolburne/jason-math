# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      module MessageAuthentication
        # HMAC
        class HashedMessageAuthenticationCode
          # rubocop:disable Naming/VariableNumber
          PARAMETERS = {
            md4: {
              class: Digest::MessageDigest,
              mode: :'4',
              block_size: 64
            }.freeze,
            sha_1: {
              class: Digest::SecureHashAlgorithm,
              mode: :'1',
              block_size: 64
            }.freeze,
            sha_224: {
              class: Digest::SecureHashAlgorithm,
              mode: :'224',
              block_size: 64
            }.freeze,
            sha_256: {
              class: Digest::SecureHashAlgorithm,
              mode: :'256',
              block_size: 64
            }.freeze,
            sha_384: {
              class: Digest::SecureHashAlgorithm,
              mode: :'384',
              block_size: 128
            }.freeze,
            sha_512: {
              class: Digest::SecureHashAlgorithm,
              mode: :'512',
              block_size: 128
            }.freeze,
            sha_512_224: {
              class: Digest::SecureHashAlgorithm,
              mode: :'512_224',
              block_size: 128
            }.freeze,
            sha_512_256: {
              class: Digest::SecureHashAlgorithm,
              mode: :'512_256',
              block_size: 128
            }.freeze,
            sha_3_224: {
              class: Digest::SecureHashAlgorithm,
              mode: :'3_224',
              block_size: 144
            }.freeze,
            sha_3_256: {
              class: Digest::SecureHashAlgorithm,
              mode: :'3_256',
              block_size: 136
            }.freeze,
            sha_3_384: {
              class: Digest::SecureHashAlgorithm,
              mode: :'3_384',
              block_size: 104
            }.freeze,
            sha_3_512: {
              class: Digest::SecureHashAlgorithm,
              mode: :'3_512',
              block_size: 72
            }.freeze
          }.freeze
          # rubocop:enable Naming/VariableNumber

          def initialize(algorithm, key)
            @algorithm = algorithm
            parameters = PARAMETERS[@algorithm]
            parameters.each_pair { |label, value| instance_variable_set("@#{label}", value) unless label == :class }
            @digest = parameters[:class].new(parameters[:mode])

            self.key = key
          end

          def key=(key)
            key = @digest.digest(key) if key.length > @block_size
            key = key.ljust(@block_size, "\x00")
            @inner_key = Utility.xor(key, "\x36" * @block_size)
            @outer_key = Utility.xor(key, "\x5c" * @block_size)
            @started = false
          end

          def update(message)
            start unless @started
            @digest << message
          end
          alias << update

          def tag(message = '')
            start unless @started
            @started = false # this is the incorrect place for this but saves a temp var
            inner_message = @digest.digest(message)
            @digest << @outer_key
            @digest.digest(inner_message)
          end

          private

          def start
            @started = true
            @digest << @inner_key
          end
        end
      end
    end
  end
end

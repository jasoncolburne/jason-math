module Jason
  module Math
    module Cryptography
      # HMAC
      class HashedMessageAuthenticationCode
        PARAMETERS = {
          sha_1: { # rubocop:disable Naming/VariableNumber
            class: SecureHashAlgorithm,
            mode: :'1',
            block_size: 64
          }.freeze,
          md4: {
            class: MessageDigest,
            mode: :'4',
            block_size: 64
          }.freeze
        }.freeze

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

        def digest(message = '')
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

# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      # The Mersenne Twister 19937 is the typical PRNG
      class MersenneTwister19937
        PARAMETERS = {
          mt19937: {
            w: 32,
            n: 624,
            m: 397,
            r: 31,
            a: 0x9908b0df,
            u: 11,
            d: 0xffffffff,
            s: 7,
            b: 0x9d2c5680,
            t: 15,
            c: 0xefc60000,
            l: 18,
            f: 1_812_433_253
          }.freeze,
          mt19937_64: { # rubocop:disable Naming/VariableNumber
            w: 64,
            n: 312,
            m: 156,
            r: 31,
            a: 0xB5026F5AA96619E9,
            u: 29,
            d: 0x5555555555555555,
            s: 17,
            b: 0x71D67FFFEDA60000,
            t: 37,
            c: 0xFFF7EEE000000000,
            l: 43,
            f: 6_364_136_223_846_793_005
          }.freeze
        }.freeze

        def initialize(algorithm = :mt19937, seed = 5489)
          parameters = PARAMETERS[algorithm]
          parameters.each_key { |key| eval "@#{key} = parameters[:#{key}]" }

          @twister = [nil] * @n
          @index = nil
          @full_mask = (1 << @w) - 1
          @lower_mask = (1 << @r) - 1
          @upper_mask = @full_mask ^ @lower_mask

          self.seed = seed
        end

        def seed=(seed)
          @index = @n
          @twister[0] = @full_mask & seed
          (1..(@n - 1)).each do |i|
            @twister[i] = @full_mask & (@f * (@twister[i - 1] ^ (@twister[i - 1] >> (@w - 2))) + i)
          end
        end

        def extract_number
          raise 'Generator has not been seeded' if @index.nil?

          twist if @index == @n

          y = @twister[@index]
          y ^= ((y >> @u) & @d)
          y ^= ((y << @s) & @b)
          y ^= ((y << @t) & @c)
          y ^= (y >> @l)

          @index += 1

          @full_mask & y
        end

        private

        def twist
          (0..(@n - 1)).each do |i|
            x = (@twister[i] & @upper_mask) + (@twister[(i + 1) % @n] & @lower_mask)
            x_a = x >> 1
            x_a ^= @a unless (x % 2).zero?
            @twister[i] = (@twister[(i + @m) % @n] ^ x_a)
          end

          @index = 0
        end
      end
    end
  end
end

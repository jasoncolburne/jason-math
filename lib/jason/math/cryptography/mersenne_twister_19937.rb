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
          @full_mask, @lower_mask, @upper_mask = self.class.create_masks(@w, @r)

          self.seed = seed
        end

        def seed=(seed)
          raise "Invalid seed" unless seed.is_a? Integer

          @index = @n
          @twister[0] = @full_mask & seed
          (1..(@n - 1)).each do |i|
            @twister[i] = @full_mask & (@f * (@twister[i - 1] ^ (@twister[i - 1] >> (@w - 2))) + i)
          end
        end

        def extract_number
          twist if @index == @n

          number = temper(@twister[@index])
          @index += 1
          number & @full_mask
        end

        def splice_state(state)
          @twister = state.dup
        end

        def self.create_masks(w, r)
          full_mask = (1 << w) - 1
          lower_mask = (1 << r) - 1
          upper_mask = full_mask ^ lower_mask
          [full_mask, lower_mask, upper_mask]
        end

        def self.untemper(value, algorithm = :mt19937)
          w, r, l, t, s, u, c, b, d = [nil] * 9
          parameters = PARAMETERS[algorithm]
          parameters.each_pair { |k, v| binding.local_variable_set(k, v) }

          full_mask, _lower_mask, _upper_mask = create_masks(w, r)

          y = value

          y = invert_shift_and_xor(y, :right, l, full_mask, w)
          y = invert_shift_and_xor(y, :left, t, c, w)
          y = invert_shift_and_xor(y, :left, s, b, w)
          y = invert_shift_and_xor(y, :right, u, d, w)

          y & full_mask
        end

        private

        def self.invert_shift_and_xor(value, direction, magnitude, mask, w)
          value = value.to_s(2).chars.map(&:to_i)
          mask = mask.to_s(2).chars.map(&:to_i)

          value.unshift(0) while value.length < w
          length.unshift(0) while mask.length < w

          if direction == :left
            value.reverse!
            mask.reverse!
          end

          x = [nil] * w
          w.times do |n|
            x[n] = if n < magnitude
                     value[n]
                   else
                     value[n] ^ (mask[n] & x[n - magnitude])
                   end
          end

          x.reverse! if direction == :left
          x.map(&:to_s).join.to_i(2)
        end

        def twist
          (0..(@n - 1)).each do |i|
            x = (@twister[i] & @upper_mask) + (@twister[(i + 1) % @n] & @lower_mask)
            x_a = x >> 1
            x_a ^= @a unless (x % 2).zero?
            @twister[i] = (@twister[(i + @m) % @n] ^ x_a)
          end

          @index = 0
        end

        def temper(value)
          y = value
          y ^= ((y >> @u) & @d)
          y ^= ((y << @s) & @b)
          y ^= ((y << @t) & @c)
          y ^ (y >> @l)
        end
      end
    end
  end
end

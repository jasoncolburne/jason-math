# frozen_string_literal: true

require 'base64'

require 'jason/math/utility/disjoint_set'
require 'jason/math/utility/completion_estimator'
require 'jason/math/utility/language_detector'

module Jason
  module Math
    # Routines that didn't fit neatly in another area
    module Utility # rubocop:disable Metrics/ModuleLength
      def self.binary_search(array, value)
        l = 0
        r = array.count - 1

        while l <= r
          i = (l + r) / 2

          if array[i] < value
            l = i + 1
          elsif array[i] > value
            r = i - 1
          else
            return i
          end
        end

        nil
      end

      # do not set dimension when calling - used recursively
      def self.neighbouring_cells(cell, dimension = nil) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        return [] if cell.empty?

        # we'll cache each dimension's method as we derive it
        @neighbouring_cells_methods ||= {}

        dimensions = cell.count
        d = dimension || dimensions
        padding = ' ' * (dimensions - d) * 2

        if @neighbouring_cells_methods[d].nil? || dimension
          string = ''
          if d.zero?
            coordinates = (0..(dimensions - 1)).map { |n| "x#{n}" }.join(', ')
            string += padding + "neighbour = [#{coordinates}]\n"
            string += "#{padding}neighbour == cell ? nil : neighbour\n"
          else
            string += padding + "((cell[#{d - 1}] - 1)..(cell[#{d - 1}] + 1)).map do |x#{d - 1}|\n"
            string += neighbouring_cells(cell, d - 1)
            string += "#{padding}end\n"
          end

          @neighbouring_cells_methods[d] = string.chomp + ".flatten(#{d - 1}).compact\n" if dimension.nil?
        end

        dimension.nil? ? eval(@neighbouring_cells_methods[d]) : string # rubocop:disable Security/Eval
      end

      def self.adjacent_cells(cell)
        adjacent_cells = []

        cell.each_with_index do |_value, index|
          cell_negative = cell.dup
          cell_positive = cell.dup

          cell_negative[index] -= 1
          cell_positive[index] += 1

          adjacent_cells << cell_negative
          adjacent_cells << cell_positive
        end

        adjacent_cells
      end

      def self.circular_array_generator(array)
        array = array.dup

        Enumerator.new do |yielder|
          unless array.empty?
            if array.count == 1
              to_yield = array.first
              loop { yielder << to_yield }
            else
              i = 0
              count = array.count
              loop do
                yielder << array[i]
                i += 1
                i = 0 if i == count
              end
            end
          end
        end
      end

      def self.hex_to_base64(hex_string)
        byte_string_to_base64(hex_to_byte_string(hex_string))
      end

      def self.base64_to_byte_string(base64_string)
        Base64.decode64(base64_string)
      end

      def self.byte_string_to_base64(byte_string)
        Base64.encode64(byte_string)
      end

      def self.hex_to_byte_string(hex_string)
        [hex_string].pack('H*')
      end

      def self.byte_string_to_hex(byte_string)
        byte_string.unpack1('H*')
      end

      def self.hex_to_byte_array(hex_string)
        hex_to_byte_string(hex_string).bytes
      end

      def self.xor(*args)
        if args.first.is_a? Array
          length = args.first.first.length

          raise 'Inputs must have equal length' unless args.first.all? { |value| value.length == length }

          args.first.inject("\x00" * length) { |a, b| xor(a, b) }
        else
          a = args[0]
          b = args[1]

          raise 'Inputs must have equal length' unless a.length == b.length

          a.bytes.zip(b.bytes).map { |x, y| (x ^ y).chr }.join
        end
      end

      def self.and(a, b)
        raise 'Inputs must have equal length' unless a.length == b.length

        a.bytes.zip(b.bytes).map { |x, y| (x & y).chr }.join
      end

      def self.or(a, b)
        raise 'Inputs must have equal length' unless a.length == b.length

        a.bytes.zip(b.bytes).map { |x, y| (x | y).chr }.join
      end

      def self.not(n)
        n.bytes.map { |x| (~x % 256).chr }.join
      end

      def self.integer_to_byte_string(n)
        result = []

        until n.zero?
          result.unshift(n & 0xff)
          n >>= 8
        end

        result.pack('C*')
      end

      def self.byte_string_to_integer(byte_string)
        byte_string.unpack('C*').reverse.each_with_index.inject(0) do |sum, (byte, index)|
          sum + byte * (256**index)
        end
      end

      def self.longest_common_substring(strings)
        shortest = strings.min_by(&:length)
        max_length = shortest.length
        max_length.downto(0) do |length|
          0.upto(max_length - length) do |start|
            substring = shortest[start, length]
            return substring if strings.all? { |s| s.include?(substring) }
          end
        end
      end

      def self.rotate_right(value, count, mask = 0xffffffff)
        total_bits = mask == 0xffffffff ? 32 : 64 # this is pretty jank
        (value >> count) | (value << (total_bits - count)) & mask
      end

      def self.rotate_left(value, count, mask = 0xffffffff)
        total_bits = mask == 0xffffffff ? 32 : 64 # this is pretty jank
        (value << count) & mask | (value >> (total_bits - count))
      end
    end
  end
end

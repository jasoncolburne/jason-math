require 'jason/math/utility/disjoint_set'
require 'jason/math/utility/completion_estimator'

module Jason
  module Math
    module Utility
      def self.binary_search(array, value)
        l = 0
        r = array.count - 1

        while l <= r
          i = (l + r) / 2

          if array[i] < value then
              l = i + 1
          elsif array[i] > value then
              r = i - 1
          else
              return i
          end
        end

        nil
      end

      # do not set dimension when calling - used recursively
      def self.neighbouring_cells(cell, dimension = nil)
        return [] if cell.empty?

        # we'll cache each dimension's method as we derive it
        @neighbouring_cells_methods ||= {}

        dimensions = cell.count
        d = dimension || dimensions
        padding = " " * (dimensions - d) * 2
      
        if @neighbouring_cells_methods[d].nil? || dimension
          string = ""
          if d.zero?
            coordinates = (0..(dimensions - 1)).map { |n| "x#{n}" }.join(", ")
            string += padding + "neighbour = [#{coordinates}]\n"
            string += padding + "neighbour == cell ? nil : neighbour\n"
          else
            string += padding + "((cell[#{d - 1}] - 1)..(cell[#{d - 1}] + 1)).map do |x#{d - 1}|\n"
            string += neighbouring_cells(cell, d - 1)
            string += padding + "end\n"
          end
      
          @neighbouring_cells_methods[d] = string.chomp + ".flatten(#{d - 1}).compact\n" if dimension.nil?
        end
      
        dimension.nil? ? eval(@neighbouring_cells_methods[d]) : string
      end

      def self.adjacent_cells(cell)
        adjacent_cells = []

        cell.each_with_index do |value, index|
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
              yielder << to_yield while true
            else
              i = 0
              count = array.count
              while true
                yielder << array[i]
                i += 1
                i = 0 if i == count
              end
            end
          end
        end
      end
    end
  end
end

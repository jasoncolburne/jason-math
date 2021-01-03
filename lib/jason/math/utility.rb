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

      def self.neighbouring_cells(cell, dimensions = nil)
        return [] if cell.empty?

        # we'll cache each dimension's method as we derive it
        @neighbouring_cells_methods ||= {}

        d = dimensions || cell.count
      
        if @neighbouring_cells_methods[d].nil? || dimensions
          string = ""
          if d.zero?
            coordinates = (0..(cell.count - 1)).map { |n| "x#{n}" }.join(", ")
            string += "neighbour = [#{coordinates}]\n"
            string += "neighbour == cell ? nil : neighbour\n"
          else
            string += "((cell[#{d - 1}] - 1)..(cell[#{d - 1}] + 1)).map do |x#{d - 1}|\n"
            string += neighbouring_cells(cell, d - 1)
            string += "end\n"
          end
      
          @neighbouring_cells_methods[d] = string.chomp + ".flatten(#{d - 1}).compact\n" if dimensions.nil?
        end
      
        dimensions.nil? ? eval(@neighbouring_cells_methods[d]) : string
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
              yielder.yield to_yield while true
            else
              i = 0
              count = array.count
              while true
                yielder.yield array[i]
                i += 1
                i = 0 if i == count
              end
            end
          end
        end
      end

      def self.partitions(array)
        Enumerator.new do |yielder|
          _partitions(array, yielder)
        end
      end

      private

      def self._partitions(array, yielder = nil)
        if array.empty?
          return [[]]
        else
          a = array.pop
          sub_response = _partitions(array)
          response = []
          sub_response.each do |partition|
            response << [[a]] + partition
            yielder.yield [[a]] + partition if yielder
            partition.each do |set|
              _partition = partition.dup
              _partition.delete_at(_partition.index(set))

              response << [set + [a]] + _partition
              yielder.yield [set + [a]] + _partition if yielder
            end
          end
          response
        end
      end

      def self.copy_2d_array(array)
        array.inject([]) { |array, element| array << element }
      end
    end
  end
end

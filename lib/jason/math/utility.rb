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

      def self.enumerate_partitions(array)
        partition = [array.dup]        
        number_of_elements = array.count
        indexes = Array.new(number_of_elements, 0)

        Enumerator.new do |yielder|
          while true
            yielder << partition.inject([]) { |collector, part| collector << part.dup }

            i = number_of_elements - 1
            index = nil
            done = false

            while true
              if i <= 0
                done = true
                break
              end
              index = indexes[i]
              partition[index].pop
              break unless partition[index].empty?
              partition.delete_at(index)
              i -= 1
            end

            break if done

            index += 1
            partition << [] if index >= partition.count

            while i < number_of_elements
              indexes[i] = index
              partition[index] << array[i]
              index = 0
              i += 1
            end
          end
        end
      end
    end
  end
end

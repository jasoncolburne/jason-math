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
    end
  end
end

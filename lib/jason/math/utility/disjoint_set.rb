# frozen_string_literal: true

module Jason
  module Math
    module Utility
      # https://en.wikipedia.org/wiki/Disjoint-set_data_structure
      class DisjointSet
        def initialize(elements)
          @parents_by_children = {}
          elements.each do |element|
            @parents_by_children[element] = element
          end
        end

        def find(element)
          return element if @parents_by_children[element] == element

          find(@parents_by_children[element])
        end

        def union(a, b)
          @parents_by_children[find(a)] = find(b)
        end
      end
    end
  end
end

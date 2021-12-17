# frozen_string_literal: true

require 'rb_heap'

module Jason
  module Math
    module GraphTheory
      class Graph
        def initialize(vertices)
          @vertices = vertices
          @graph = Hash.new { |h, k| h[k] = [] }
        end

        def add_edge(origin, destination, weight = 1, validate = false)
          raise "unexpected vertices (#{origin}, #{destination})!" if validate && ![origin,
                                                                                    destination].all? do |vertex|
                                                                        @vertices.include?(vertex)
                                                                      end

          @graph[origin] << { vertex: destination, weight: weight }
        end

        def dijkstra(origin, destination)
          distances = (@vertices - [origin]).zip([Float::INFINITY] * (@vertices.count - 1)).to_h
          distances[origin] = 0

          heap = Heap.new { |a, b| distances[a] < distances[b] }
          heap << origin

          until heap.empty?
            vertex = heap.pop
            @graph[vertex].each do |edge|
              if distances[edge[:vertex]] > distances[vertex] + edge[:weight]
                distances[edge[:vertex]] = distances[vertex] + edge[:weight]
                heap << edge[:vertex]
              end
            end
          end

          distances[destination]
        end

        alias shortest_path dijkstra

        def longest_path(origin, destination)
          negate_edge_weights
          distance = dijkstra(origin, destination)
          negate_edge_weights
          -distance
        end

        def kruskal
          minimum_spanning_tree = []

          edges = []
          @graph.each do |origin, aggregates|
            aggregates.each do |aggregate|
              edges << { origin: origin, destination: aggregate[:vertex], weight: aggregate[:weight] }
            end
          end
          edges.sort_by! { |aggregate| aggregate[:weight] }

          disjoint_set = Utility::DisjointSet.new(@vertices)

          tree_size = @vertices.count - 1
          max_index = edges.count - 1

          index = 0
          while minimum_spanning_tree.count < tree_size && index < max_index
            aggregate = edges[index]
            index += 1

            a = disjoint_set.find(aggregate[:origin])
            b = disjoint_set.find(aggregate[:destination])

            if a != b
              minimum_spanning_tree << aggregate
              disjoint_set.union(a, b)
            end
          end

          minimum_spanning_tree.count == tree_size ? minimum_spanning_tree : nil
        end

        alias minimum_spanning_tree kruskal

        private

        def negate_edge_weights
          @graph.each_value do |edges|
            edges.each do |edge|
              edge[:weight] = -edge[:weight]
            end
          end
        end
      end
    end
  end
end

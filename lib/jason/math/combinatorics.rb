module Jason
  module Math
    module Combinatorics
      def self.factorial(n)
        return 1 if n.zero?
        (1..n).inject(&:*)
      end
      
      def self.nCk(n, k)
        nPk(n, k) / factorial(k)
      end

      def self.nPk(n, k)
        factorial(n) / factorial(n - k)
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
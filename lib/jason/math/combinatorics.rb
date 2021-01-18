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

      # https://jeromekelleher.net/generating-integer-partitions.html
      def self.enumerate_integer_partitions(n)
        a = [0] * n
        k = 1
        y = n - 1

        Enumerator.new do |yielder|
          while k != 0
            x = a[k - 1] + 1
            k -= 1
            while 2 * x <= y
              a[k] = x
              y -= x
              k += 1
            end
            l = k + 1
            while x <= y
              a[k] = x
              a[l] = y
              yielder << a[0..(k + 1)]
              x += 1
              y -= 1
            end
            a[k] = x + y
            y = x + y - 1
            yielder << a[0..k]
          end
        end
      end

      # https://stackoverflow.com/questions/14053885/integer-partition-algorithm-and-recursion
      def self.count_integer_partitions(n, max = n)
        return 1 + count_integer_partitions(n, max - 1) if n == max
        return 0 if max == 0 || n < 0
        return 1 if n == 0 || max == 1
        count_integer_partitions(n, max - 1) + count_integer_partitions(n - max, max)
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
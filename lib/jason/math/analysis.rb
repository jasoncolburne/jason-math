module Jason
  module Math
    module Analysis
      def self.collatz_sequence(n, sequence = [])
        sequence << n
      
        if n % 2 == 0
          collatz_sequence(n / 2, sequence)
        elsif n != 1
          collatz_sequence(3 * n + 1, sequence)
        end
      
        sequence
      end

      def self.root_as_continued_fraction(n)
        result = []
        subresult = []

        limit = (n ** 0.5).to_i

        m = 0
        d = 1
        a = limit
        result << a

        seen = Set[]
        until seen.include?([m, d, a])
          subresult << a unless seen.empty?
          seen << [m, d, a]
          m = d * a - m
          d = (n - m * m) / d
          a = (limit + m) / d
        end

        result << subresult
        result
      end
    end
  end
end

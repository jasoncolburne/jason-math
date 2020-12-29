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

        unless limit == n ** 0.5
          seen = Set[]
          until seen.include?([m, d, a])
            subresult << a unless seen.empty?
            seen << [m, d, a]
            m = d * a - m
            d = (n - m * m) / d
            a = (limit + m) / d
          end
        end

        result << subresult
        result
      end

      def self.evaluate_continued_fraction(fraction, depth = 42)
        return fraction[0] if fraction[1].is_a?(Array) && fraction[1].empty?

        generator = fraction[1].is_a?(Array) ? Utility.circular_array_generator(fraction[1]) : fraction[1]

        return Rational(fraction[0], 1) if depth.zero?

        fraction[0] + Rational(1, recursively_evaluate_continued_fraction(generator, depth))
      end

      def self.continued_fraction_for(constant)
        case constant
        when :e
          e_continued_fraction_generator = Enumerator.new do |yielder|
            i = 1
            while true
              yielder.yield 1
              yielder.yield 2 * i
              yielder.yield 1
              i += 1
            end
          end

          [2, e_continued_fraction_generator]
        when :phi # golden ratio
          [1, [1]]
        else
          raise "unsupported constant"
        end
      end

      private

      def self.recursively_evaluate_continued_fraction(generator, depth, iterations = 1)
        if iterations == depth
          generator.next
        else
          value = generator.next
          value + Rational(1, recursively_evaluate_continued_fraction(generator, depth, iterations + 1))
        end
      end
    end
  end
end

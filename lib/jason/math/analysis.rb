# frozen_string_literal: true

module Jason
  module Math
    # Analysis
    module Analysis
      def self.collatz_sequence(n, sequence = [])
        sequence << n

        if n.even?
          collatz_sequence(n / 2, sequence)
        elsif n != 1
          collatz_sequence(3 * n + 1, sequence)
        end

        sequence
      end

      def self.fibonacci_enumerator
        Enumerator.new do |yielder|
          nk = 0
          nk1 = 1
          yielder << nk
          yielder << nk1

          loop do
            nk2 = nk1 + nk
            yielder << nk2
            nk = nk1
            nk1 = nk2
          end
        end
      end

      def self.fibonacci_term(n)
        fibonacci_enumerator.take(n + 1).last
      end

      def self.fibonacci_terms_below(limit)
        fibonacci_enumerator.take_while { |n| n < limit }
      end

      def self.root_as_continued_fraction(n)
        result = []
        subresult = []

        limit = (n**0.5).to_i

        m = 0
        d = 1
        a = limit
        result << a

        unless limit == n**0.5 # rubocop:disable Lint/FloatComparison
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
            loop do
              yielder << 1
              yielder << 2 * i
              yielder << 1
              i += 1
            end
          end

          [2, e_continued_fraction_generator]
        when :phi # golden ratio
          [1, [1]]
        else
          raise 'unsupported constant'
        end
      end

      def self.recursively_evaluate_continued_fraction(generator, depth, iterations = 1)
        if iterations == depth
          generator.next
        else
          generator.next + Rational(1, recursively_evaluate_continued_fraction(generator, depth, iterations + 1))
        end
      end
    end
  end
end

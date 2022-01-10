# frozen_string_literal: true

module Jason
  module Math
    # Algebra
    module Algebra
      def self.solve_quadratic(a, b, c)
        # we don't need to do anything special with the discriminant because
        # ruby privides complex numbers out of the box
        discriminant_root = (b**2 - 4 * a * c)**0.5
        divisor = 2 * a

        [(-b + discriminant_root) / divisor, (-b - discriminant_root) / divisor].uniq
      end

      # finds y, the integer component of the nth root of n
      # such that y ** n <= x < (y + 1) ** n
      def self.root(x, n = 2)
        high = 1

        high *= 2 while high**n <= x
        low = high / 2

        while low < high
          mid = (low + high) / 2
          if low < mid && mid**n < x
            low = mid
          elsif high > mid && mid**n > x
            high = mid
          else
            return mid
          end
        end

        mid + 1
      end
    end
  end
end

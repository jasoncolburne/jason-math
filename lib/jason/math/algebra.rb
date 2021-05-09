module Jason
  module Math
    module Algebra
      def self.solve_quadratic(a, b, c)
        # we don't need to do anything special with the discriminant because
        # ruby privides complex numbers out of the box
        discriminant = (b ** 2 - 4 * a * c) ** 0.5
        divisor = 2 * a

        [(-b + discriminant) / divisor, (-b - discriminant) / divisor].uniq
      end
    end
  end
end

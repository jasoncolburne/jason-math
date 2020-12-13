module Jason
  module Math
    module Combinatorics
      def self.factorial(n)
        (1..n).inject(&:*)
      end
      
      def self.n_choose_k(n, k)
        factorial(n) / (factorial(k) * factorial(n - k))
      end
    end
  end
end
module Jason
  module Math
    module Combinatorics
      def self.factorial(n)
        return 1 if n.zero?
        (1..n).inject(&:*)
      end
      
      def self.n_c_k(n, k)
        n_p_k(n, k) / factorial(k)
      end

      def self.n_p_k(n, k)
        factorial(n) / factorial(n - k)
      end
    end
  end
end
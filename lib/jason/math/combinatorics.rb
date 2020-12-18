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
    end
  end
end
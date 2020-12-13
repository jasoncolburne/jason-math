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
    end
  end
end
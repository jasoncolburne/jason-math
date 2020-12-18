require 'openssl'
require 'prime'
require 'set'

module Jason
  module Math
    module NumberTheory
      def self.prime(offset)
        prime_generator = Prime::EratosthenesGenerator.new
        (offset - 1).times { prime_generator.take(1) }
        prime_generator.take(1).first
      end

      def self.primes(count)
        Prime::EratosthenesGenerator.new.take(count)
      end
      
      def self.primes_below(limit)
        Prime::EratosthenesGenerator.new.take_while { |prime| prime < limit }
      end

      def self.prime?(number)
        prime_generator = Prime::EratosthenesGenerator.new

        root_n = number ** 0.5

        while (prime = prime_generator.take(1).first) <= root_n
          return false if number % prime == 0
        end

        prime > root_n
      end

      # returns a hash like { p1 => e1, p2 => e2 } where p1, p2 are primes and e1, e2
      # are their exponents
      def self.factors(number)
        factors = Hash.new(0)
 
        prime_generator = Prime::EratosthenesGenerator.new
        root_n = number ** 0.5

        while number > 1
          prime = prime_generator.take(1).first

          if prime > root_n
            factors[number] += 1
            break
          end

          while number % prime == 0
            number /= prime
            factors[prime] += 1
          end
        end
      
        factors
      end
      
      # returns a set, do with it what you will
      def self.divisors(number)
        divisors = Set[1]
        all_primes = factors(number).map { |p, n| [p] * n }.flatten
      
        (1..all_primes.count).each do |n|
          all_primes.combination(n).each do |combination|
            divisors << combination.inject(&:*)
          end
        end
      
        divisors
      end

      # also returns a set
      def self.proper_divisors(number)
        divisors(number) - Set[number]
      end
      
      def self.co_prime?(numbers)
        factor_sets = numbers.map { |number| factors(number).keys.to_set }
        limit = factor_sets.length
        factor_sets.each_with_index do |factors, index|
          return true if index == limit - 1
          return false unless factor_sets[(index + 1)..].all? { |set| factors.intersection(set).empty? }
        end
      end

      def self.perfect?(number)
        proper_divisors(number).sum == number
      end

      def self.deficient?(number)
        proper_divisors(number).sum < number
      end

      def self.abundant?(number)
        proper_divisors(number).sum > number
      end

      def self.palindrome?(number)
        number.to_s == number.to_s.reverse
      end

      def self.lychrel?(number, depth = 50)
        while depth > 0
          next_number = number + reverse(number)
          return false if palindrome?(next_number)
          number = next_number
          depth -= 1
        end

        true
      end

      def self.reverse(number)
        number.to_s.reverse.to_i
      end
      
      def self.chinese_remainder_theorem(mapping)
        raise "moduli not co-prime" unless co_prime?(mapping.keys)
      
        max = mapping.keys.inject(&:*)
        series = mapping.map { |m, r| (r * max * (max/m).to_bn.mod_inverse(m) / m) }
        series.inject(&:+) % max     
      end
      
      def self.triangular_number(offset)
        (offset * (offset + 1)) / 2
      end
    end
  end
end
require 'openssl'
require 'set'

module Jason
  module Math
    module NumberTheory
      def self.primes(count)
        primes = Set[]
        divisor = 2
        while primes.count < count
          primes << divisor unless primes.any? { |p| divisor % p == 0 }
          # puts "#{divisor} (#{primes.count})" if divisor % 10000 == 0
          divisor += 1
        end
        primes
      end
        
      def self.primes_below(limit)
        primes = Set[]
        divisor = 2
        while divisor < limit
          primes << divisor unless primes.any? { |p| divisor % p == 0 }
          # puts "#{divisor} (#{primes.count})" if divisor % 10000 == 0
          divisor += 1
        end
        primes
      end
        
      def self.prime_factors(number)
        factors = Hash.new(0)
        primes = Set[]
      
        divisor = 2
        while number > 1 && divisor < number ** 0.5 + 1
          prime = primes.none? { |p| divisor % p == 0 }
          primes << divisor if prime
      
          if prime && number % divisor == 0
            while number % divisor == 0
              number /= divisor
              factors[divisor] += 1
            end
          end
      
          divisor += 1
        end
        factors[number] += 1 if number != 1 && primes.none? { |p| number % p == 0 }
      
        factors
      end
      
      def self.factors(number)
        prime_factors = prime_factors(number)
        factors = Set[1, number]
        all_primes = prime_factors.map { |p, n| [p] * n }.flatten
      
        (1..all_primes.count).each do |n|
          all_primes.combination(n).each do |combination|
            factors << combination.inject(&:*)
          end
        end
      
        factors
      end
      
      def self.co_prime?(numbers)
        factor_sets = numbers.map { |modulus| prime_factors(modulus).keys.to_set }
        limit = factor_sets.length
        factor_sets.each_with_index do |factors, index|
          return true if index == limit - 1
          return false unless factor_sets[(index + 1)..].all? { |set| factors.intersection(set).empty? }
        end
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
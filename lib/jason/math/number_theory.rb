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

          if number % prime == 0
            while number % prime == 0
              number /= prime
              factors[prime] += 1
            end

            root_n = number ** 0.5
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

      def self.gcd(u, v)
        # gcd(n, n) = n
        return u if u == v

        # gcd(0, n) = gcd(n, 0) = n
        return v if u == 0
        return u if v == 0

        if u.even?
          if v.odd?
            gcd(u / 2, v)
          else
            2 * gcd(u / 2, v / 2)
          end
        else
          if v.even?
            gcd(u, v / 2)
          else
            if u > v
              gcd((u - v) / 2, v)
            else
              gcd((v - u) / 2, u)
            end
          end
        end
      end

      def self.lcm(u, v)
        return 0 if u == 0 && v == 0
        (u * v) / gcd(u, v)
      end

      def self.totient(number)
        result = number;
        root_n = (number ** 0.5).to_i

        (2..root_n).each do |i|
          if number % i == 0
            while number % i == 0
              number /= i
            end
            result -= result / i
          end
        end

        number > 1 ? result - result / number : result
      end
      
      def self.co_prime?(numbers)
        # look for duplicates, as this allows us to make assumptions later on
        return false if numbers.to_set.count != numbers.count

        numbers = numbers.dup
        prime_generator = Prime::EratosthenesGenerator.new
        root_max_n = numbers.max ** 0.5

        while (prime = prime_generator.take(1).first) < root_max_n && numbers.reject { |n| n == 1 }.count > 1
          divisible = numbers.select { |number| number % prime == 0 }
          return false if divisible.count > 1

          divisible.each do |number|
            new_number = number
            while new_number % prime == 0
              new_number = new_number / prime
            end
            numbers[numbers.index(number)] = new_number
            # we'd need to do the numbers.max call twice to check if it changed and i think just doing it once 
            # taking the root every time will be faster
            root_max_n = numbers.max ** 0.5
          end
        end

        true
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
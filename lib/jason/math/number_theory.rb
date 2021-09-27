require 'openssl'
require 'prime'
require 'set'

module Jason
  module Math
    module NumberTheory
      def self.prime(offset)
        prime_generator = Prime::EratosthenesGenerator.new
        (offset - 1).times { prime_generator.take(1) }
        prime_generator.next
      end

      def self.primes(count)
        Prime::EratosthenesGenerator.new.take(count)
      end
      
      def self.primes_below(limit)
        Prime::EratosthenesGenerator.new.take_while { |prime| prime < limit }
      end

      def self.prime?(number, below = nil)
        return false if number < 2

        prime_generator = Prime::EratosthenesGenerator.new
        root_n = number ** 0.5

        while (prime = prime_generator.next) <= root_n && (below.nil? || prime < below)
          return false if number % prime == 0
        end

        true
      end

      def self.prime_by_weak_fermat?(number, iterations = nil)
        return false if number < 2

        iterations ||= number.to_s(2).length / 2 + 1
        iterations.times do
          # TODO use a better RNG
          a = rand(number - 4) + 2
          return false unless a.to_bn.mod_exp((number - 1), number) == 1
        end

        true
      end

      def self.prime_by_miller_rabin?(number, iterations = nil)
        return false if number < 2

        r = 0
        d = number - 1
        while d % 2 == 0
          d /= 2
          r += 1
        end

        iterations ||= number.to_s(2).length / 2 + 1
        iterations.times do
          # TODO use a better RNG
          a = rand(number - 4) + 2
          x = a.to_bn.mod_exp(d, number)
          next if x == 1 or x == number - 1
          probably_prime = false
          (r - 1).times do
            x = x.mod_exp(2, number)
            if x == number - 1
              probably_prime = true
              break
            end
          end

          return false unless probably_prime
        end

        true
      end

      def self.probably_prime?(number, sieve_below = 1299709, iterations_of_fermat = nil, iterations_of_miller_rabin = nil)
        return false unless prime?(number, sieve_below)

        if number < sieve_below * sieve_below
          true
        else
          prime_by_weak_fermat?(number, iterations_of_fermat) && prime_by_miller_rabin?(number, iterations_of_miller_rabin)
        end
      end

      # returns a hash like { p1 => e1, p2 => e2 } where p1, p2 are primes and e1, e2
      # are their exponents
      def self.factors(number)
        factors = Hash.new(0)
        prime_generator = Prime::EratosthenesGenerator.new
        root_n = number ** 0.5

        while number > 1
          prime = prime_generator.next

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

      # returns a flat array with duplicated factors
      def self.factor_array(number)
        factors(number).map { |p, n| [p] * n }.flatten
      end
      
      def self.divisors(number)
        enumerate_divisors(number).to_a
      end

      def self.proper_divisors(number)
        enumerate_divisors(number, true).to_a
      end

      def self.enumerate_divisors(number, proper = false)
        factors_array = factors(number).to_a
        factor_count = factors_array.count
        exponents = [0] * factor_count

        Enumerator.new do |yielder|
          if number < 2
            yielder << 1 if number == 1 && !proper
          else
            catch :done do
              while true
                result = (0..(factor_count - 1)).map { |x| factors_array[x][0] ** exponents[x] }.inject(1, :*)
                yielder << result unless proper && result == number
                i = 0
                while true
                  exponents[i] += 1
                  break if exponents[i] <= factors_array[i][1]
                  exponents[i] = 0
                  i += 1
                  throw :done if i >= factor_count
                end
              end
            end
          end
        end
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
        max = (number ** 0.5).to_i

        (2..max).each do |i|
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

        while (prime = prime_generator.next) < root_max_n && numbers.reject { |n| n == 1 }.count > 1
          divisible = numbers.select { |number| number % prime == 0 }
          return false if divisible.count > 1

          divisible.each do |number|
            index = numbers.index(number)
            number /= prime while number % prime == 0
            numbers[index] = number

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

      def self.palindrome?(number, base = 10)
        string = number.to_s(base)
        string == string.reverse
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

      def self.harshad?(number)
        number % number.digits.sum == 0
      end

      def self.right_truncatable_harshad?(number)
        while number > 10
          return false unless number.harshad?
          number /= 10
        end

        true
      end

      def self.strong_harshad?(number)
        number.harshad? && (number / number.digits.sum).probably_prime?
      end

      def self.strong_right_truncatable_harshad_prime?(number)
        return false unless number.probably_prime? && number > 9

        (number / 10).strong_harshad? && (number / 10).right_truncatable_harshad?
      end

      def self.pandigital?(numbers, initial = 1)
        digits = numbers.is_a?(Integer) ? numbers.digits : numbers.map(&:digits).flatten
        max = digits.count - (1 - initial)
        return false unless (initial..max).to_set == digits.to_set
        true
      end

      # note: negative numbers will lose their sign in this method
      def self.digits(number, base = 10)
        return [0] if number.zero?

        number = number.abs if number < 0

        digits = []
        while number > 0
          digits.unshift(number % base)
          number /= base
        end
        digits
      end

      def self.reverse(number)
        number.to_s.reverse.to_i
      end

      def self.concatenate_with_strings(numbers)
        numbers.map(&:to_s).join.to_i
      end

      def self.concatenate(numbers)
        result = 0
        digits = 0

        i = numbers.count - 1
        while i >= 0
          n = numbers[i]
          result += n * 10 ** digits
          if n.zero?
            digits += 1
          else
            digits += ::Math.log10(n).to_i + 1
          end
          i-= 1
        end

        result
      end
      
      def self.chinese_remainder_theorem(mapping, enforce_co_primality = true)
        if enforce_co_primality
          raise "moduli not co-prime" unless co_prime?(mapping.keys)
        end
      
        max = mapping.keys.inject(&:*)
        series = mapping.map { |m, r| (r * max * (max/m).to_bn.mod_inverse(m) / m) }
        series.inject(&:+) % max     
      end
      
      def self.polygonal_number(n, offset)
        if n < 3
          raise "no polygon with #{n} sides"
        elsif n == 3
          (offset * offset + offset) / 2
        else
          ((n - 2) * offset - (n - 4)) * offset / 2
        end
      end

      def self.legendre_symbol(a, p)
        ls = modular_exponentiation(a, (p - 1) / 2, p)
        ls == p - 1 ? -1 : ls
      end

      def self.modular_exponentiation(base, exponent, modulus)
        bits = exponent.to_s(2)
        x = 1
        bits.each_char do |bit|
          x = x * x % modulus
          x = x * base % modulus if bit == '1'
        end
        x
      end

      # p must be prime
      def self.modular_square_roots(a, p)
        return 0 if legendre_symbol(a, p) != 1
        return 0 if a == 0
        return 0 if p == 2
        
        return modular_exponentiation(a, (p + 1) / 4, p) if p % 4 == 3
    
        # Partition p-1 to s * 2^e for an odd s (i.e.
        # reduce all the powers of 2 from p-1)
        #
        s = p - 1
        e = 0
        while s % 2 == 0 do
          s /= 2
          e += 1
        end
    
        # Find some 'n' with a legendre symbol n|p = -1.
        # Shouldn't take long.
        #
        n = 2
        n += 1 while legendre_symbol(n, p) != -1
    
        # Here be dragons!
        # Read the paper "Square roots from 1; 24, 51,
        # 10 to Dan Shanks" by Ezra Brown for more
        # information
        #
    
        # x is a guess of the square root that gets better
        # with each iteration.
        # b is the "fudge factor" - by how much we're off
        # with the guess. The invariant x^2 = ab (mod p)
        # is maintained throughout the loop.
        # g is used for successive powers of n to update
        # both a and b
        # r is the exponent - decreases with each update
        #
        x = modular_exponentiation(a, (s + 1) / 2, p)
        b = modular_exponentiation(a, s, p)
        g = modular_exponentiation(n, s, p)
        r = e
    
        while true do
          t = b
          m = 0
          (0..(r - 1)).each do |m|
            break if t == 1
            t = modular_exponentiation(t, 2, p)
          end
    
          return [x, p - x] if m == 0
    
          gs = modular_exponentiation(g, 2 ** (r - m - 1), p)
          g = (gs * gs) % p
          x = (x * gs) % p
          b = (b * g) % p
          r = m
        end
      end
      
      def self.modular_sum(numbers, modulus)
        numbers.inject(0) { |sum, n| (sum + n) % modulus }
      end

      def self.product(numbers)
        numbers.inject(1, :*)
      end

      def self.modular_product(numbers, modulus)
        numbers.inject(1) { |product, n| product * n % modulus }
      end
    end
  end
end

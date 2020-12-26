require "jason/math/version"

require "jason/math/algebra"
require "jason/math/analysis"
require "jason/math/combinatorics"
require "jason/math/graph_theory"
require "jason/math/number_theory"
require "jason/math/utility"

module Jason
  module Math
    class Error < StandardError; end
    # Your code goes here...
  end
end

module Math
  # algebra
  def self.solve_quadratic(a, b, c)
    Jason::Math::Algebra.solve_quadratic(a, b, c)
  end

  # analysis
  def self.collatz_sequence(n)
    Jason::Math::Analysis.collatz_sequence(n)
  end

  # combinatorics
  def self.factorial(n)
    Jason::Math::Combinatorics.factorial(n)
  end

  def self.nPk(n, k)
    Jason::Math::Combinatorics.nPk(n, k)
  end

  def self.nCk(n, k)
    Jason::Math::Combinatorics.nCk(n, k)
  end

  # number theory
  def self.primes(count)
    Jason::Math::NumberTheory.primes(count)
  end

  def self.primes_below(limit)
    Jason::Math::NumberTheory.primes_below(limit)
  end

  def self.factors(n)
    Jason::Math::NumberTheory.factors(n)
  end

  def self.divisors(n)
    Jason::Math::NumberTheory.divisors(n)
  end

  def self.proper_divisors(n)
    Jason::Math::NumberTheory.proper_divisors(n)
  end

  def self.perfect?(n)
    Jason::Math::NumberTheory.perfect?(n)
  end

  def self.deficient?(n)
    Jason::Math::NumberTheory.deficient?(n)
  end

  def self.abundant?(n)
    Jason::Math::NumberTheory.abundant?(n)
  end

  def self.lychrel?(n, depth = 50)
    Jason::Math::NumberTheory.lychrel?(n, depth)
  end

  def self.palindrome?(n, base = 10)
    Jason::Math::NumberTheory.palindrome?(n, base)
  end

  def self.pandigital?(numbers, initial = 1)
    Jason::Math::NumberTheory.pandigital?(numbers, initial)
  end

  def self.digits(n)
    Jason::Math::NumberTheory.digits(n)
  end

  def self.reverse(n)
    Jason::Math::NumberTheory.reverse(n)
  end

  def self.prime(offset)
    Jason::Math::NumberTheory.prime(offset)
  end

  def self.prime?(n)
    Jason::Math::NumberTheory.prime?(n)
  end

  def self.prime_by_weak_fermat?(n, iterations = nil)
    Jason::Math::NumberTheory.prime_by_weak_fermat?(n, iterations)
  end

  def self.prime_by_miller_rabin?(n, iterations = nil)
    Jason::Math::NumberTheory.prime_by_miller_rabin?(n, iterations)
  end

  def self.probably_prime?(n, sieve_below = 1299709, iterations_of_fermat = nil, iterations_of_miller_rabin = nil)
    Jason::Math::NumberTheory.probably_prime?(n, sieve_below, iterations_of_fermat, iterations_of_miller_rabin)
  end

  def self.gcd(x, y)
    Jason::Math::NumberTheory.gcd(x, y)
  end

  def self.lcm(x, y)
    Jason::Math::NumberTheory.lcm(x, y)
  end

  def self.totient(n)
    Jason::Math::NumberTheory.totient(n)
  end

  def self.co_prime?(numbers)
    Jason::Math::NumberTheory.co_prime?(numbers)
  end

  def self.chinese_remainder_theorem(values_by_moduli)
    Jason::Math::NumberTheory.chinese_remainder_theorem(values_by_moduli)
  end

  def self.triangular_number(offset)
    Jason::Math::NumberTheory.triangular_number(offset)
  end

  # utility

  def self.binary_search(array, value)
    Jason::Math::Utility.binary_search(array, value)
  end

  def self.neighbouring_cells(cell)
    Jason::Math::Utility.neighbouring_cells(cell)
  end

  def self.adjacent_cells(cell)
    Jason::Math::Utility.adjacent_cells(cell)
  end
end

class Integer
  def factorial
    Math.factorial(self)
  end

  def factors
    Math.factors(self)
  end

  def divisors
    Math.divisors(self)
  end

  def digits
    Math.digits(self)
  end

  def pandigital?(initial = 1)
    Math.pandigital?(self, initial)
  end

  def perfect?
    Math.perfect?(self)
  end

  def prime?
    Math.prime?(self)
  end

  def prime_by_weak_fermat?(iterations = nil)
    Math.prime_by_weak_fermat?(self, iterations)
  end

  def prime_by_miller_rabin?(iterations = nil)
    Math.prime_by_miller_rabin?(self, iterations)
  end

  def probably_prime?(sieve_below = 1299709, iterations_of_fermat = nil, iterations_of_miller_rabin = nil)
    Math.probably_prime?(self, sieve_below, iterations_of_fermat, iterations_of_miller_rabin)
  end

  def deficient?
    Math.deficient?(self)
  end

  def abundant?
    Math.abundant?(self)
  end

  def lychrel?(depth = 50)
    Math.lychrel?(self, depth)
  end

  def palindrome?(base = 10)
    Math.palindrome?(self, base)
  end

  def reverse
    Math.reverse(self)
  end

  def proper_divisors
    Math.proper_divisors(self)
  end

  def primes
    Math.primes(self)
  end
end

class Array
  def co_prime?
    Math.co_prime?(self)
  end

  def binary_search(value)
    Math.binary_search(self, value)
  end

  def neighbouring_cells
    Math.neighbouring_cells(self)
  end

  def adjacent_cells
    Math.adjacent_cells(self)
  end

  def pandigital?(initial = 1)
    Math.pandigital?(self, initial)
  end
end

class Set
  def co_prime?
    Math.co_prime?(self)
  end

  def pandigital?(initial = 1)
    Math.pandigital?(self, initial)
  end
end

class Hash
  def chinese_remainder_theorem
    Math.chinese_remainder_theorem(self)
  end
end
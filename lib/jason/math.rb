require "jason/math/version"
require "jason/math/analysis"
require "jason/math/combinatorics"
require "jason/math/graph_theory"
require "jason/math/number_theory"

module Jason
  module Math
    class Error < StandardError; end
    # Your code goes here...
  end
end

module Math
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

  def self.palindrome?(n)
    Jason::Math::NumberTheory.palindrome?(n)
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

  def self.co_prime?(numbers)
    Jason::Math::NumberTheory.co_prime?(numbers)
  end

  def self.chinese_remainder_theorem(values_by_moduli)
    Jason::Math::NumberTheory.chinese_remainder_theorem(values_by_moduli)
  end

  def self.triangular_number(offset)
    Jason::Math::NumberTheory.triangular_number(offset)
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

  def perfect?
    Math.perfect?(self)
  end

  def prime?
    Math.prime?(self)
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

  def palindrome?
    Math.palindrome?(self)
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
end

class Set
  def co_prime?
    Math.co_prime?(self)
  end
end

class Hash
  def chinese_remainder_theorem
    Math.chinese_remainder_theorem(self)
  end
end
require "jason/math/version"
require "jason/math/analysis"
require "jason/math/combinatorics"
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

  def self.n_choose_k(n, k)
    Jason::Math::Combinatorics.n_choose_k(n, k)
  end

  # number theory
  def self.primes(count)
    Jason::Math::NumberTheory.primes(count)
  end

  def self.primes_below(limit)
    Jason::Math::NumberTheory.primes_below(limit)
  end

  def self.prime_factors(n)
    Jason::Math::NumberTheory.prime_factors(n)
  end

  def self.factors(n)
    Jason::Math::NumberTheory.factors(n)
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
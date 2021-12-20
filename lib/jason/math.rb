# frozen_string_literal: true

require 'jason/math/version'

require 'jason/math/algebra'
require 'jason/math/analysis'
require 'jason/math/combinatorics'
require 'jason/math/cryptography'
require 'jason/math/graph_theory'
require 'jason/math/number_theory'
require 'jason/math/utility'

module Jason
  module Math
    class Error < StandardError; end
    # Your code goes here...
  end
end

# Enhancing Math
module Math # rubocop:disable Metrics/ModuleLength
  # algebra
  def self.solve_quadratic(a, b, c)
    Jason::Math::Algebra.solve_quadratic(a, b, c)
  end

  # analysis
  def self.collatz_sequence(n)
    Jason::Math::Analysis.collatz_sequence(n)
  end

  def self.fibonacci_enumerator
    Jason::Math::Analysis.fibonacci_enumerator
  end

  def self.fibonacci_term(n)
    Jason::Math::Analysis.fibonacci_term(n)
  end

  def self.fibonacci_terms_below(limit)
    Jason::Math::Analysis.fibonacci_terms_below(limit)
  end

  def self.root_as_continued_fraction(n)
    Jason::Math::Analysis.root_as_continued_fraction(n)
  end

  def self.evaluate_continued_fraction(fraction, depth = 42)
    Jason::Math::Analysis.evaluate_continued_fraction(fraction, depth)
  end

  def self.continued_fraction_for(constant)
    Jason::Math::Analysis.continued_fraction_for(constant)
  end

  # combinatorics
  def self.factorial(n)
    Jason::Math::Combinatorics.factorial(n)
  end

  def self.double_factorial(n)
    Jason::Math::Combinatorics.double_factorial(n)
  end

  def self.nPk(n, k) # rubocop:disable Naming/MethodName
    Jason::Math::Combinatorics.nPk(n, k)
  end

  def self.nCk(n, k) # rubocop:disable Naming/MethodName
    Jason::Math::Combinatorics.nCk(n, k)
  end

  def self.enumerate_integer_partitions(n)
    Jason::Math::Combinatorics.enumerate_integer_partitions(n)
  end

  def self.count_integer_partitions(n, max = n)
    Jason::Math::Combinatorics.count_integer_partitions(n, max)
  end

  def self.enumerate_partitions(array)
    Jason::Math::Combinatorics.enumerate_partitions(array)
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

  def self.factor_array(n)
    Jason::Math::NumberTheory.factor_array(n)
  end

  def self.divisors(n)
    Jason::Math::NumberTheory.divisors(n)
  end

  def self.proper_divisors(n)
    Jason::Math::NumberTheory.proper_divisors(n)
  end

  def self.enumerate_divisors(n, proper: false)
    Jason::Math::NumberTheory.enumerate_divisors(n, proper: proper)
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

  def self.harshad?(n)
    Jason::Math::NumberTheory.harshad?(n)
  end

  def self.right_truncatable_harshad?(n)
    Jason::Math::NumberTheory.right_truncatable_harshad?(n)
  end

  def self.strong_harshad?(n)
    Jason::Math::NumberTheory.strong_harshad?(n)
  end

  def self.strong_right_truncatable_harshad_prime?(n)
    Jason::Math::NumberTheory.strong_right_truncatable_harshad_prime?(n)
  end

  def self.palindrome?(n, base = 10)
    Jason::Math::NumberTheory.palindrome?(n, base)
  end

  def self.pandigital?(numbers, initial = 1)
    Jason::Math::NumberTheory.pandigital?(numbers, initial)
  end

  def self.digits(n, base = 10)
    Jason::Math::NumberTheory.digits(n, base)
  end

  def self.reverse(n)
    Jason::Math::NumberTheory.reverse(n)
  end

  def self.concatenate(numbers)
    Jason::Math::NumberTheory.concatenate(numbers)
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

  def self.probably_prime?(n, sieve_below = 1_299_709, iterations_of_fermat = nil, iterations_of_miller_rabin = nil)
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

  def self.chinese_remainder_theorem(values_by_moduli, enforce_co_primality: true)
    Jason::Math::NumberTheory.chinese_remainder_theorem(values_by_moduli, enforce_co_primality: enforce_co_primality)
  end

  def self.polygonal_number(n, offset)
    Jason::Math::NumberTheory.polygonal_number(n, offset)
  end

  def self.legendre_symbol(a, p)
    Jason::Math::NumberTheory.legendre_symbol(a, p)
  end

  def self.modular_exponentiation(base, exponent, modulus)
    Jason::Math::NumberTheory.modular_exponentiation(base, exponent, modulus)
  end

  # p must be prime
  def self.modular_square_roots(a, p)
    Jason::Math::NumberTheory.modular_square_roots(a, p)
  end

  def self.modular_sum(numbers, modulus)
    Jason::Math::NumberTheory.modular_sum(numbers, modulus)
  end

  def self.product(numbers)
    Jason::Math::NumberTheory.product(numbers)
  end

  def self.modular_product(numbers, modulus)
    Jason::Math::NumberTheory.modular_product(numbers, modulus)
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

# Enhancing Integer
class Integer
  def fibonacci_terms
    Math.fibonacci_enumerator.take(self)
  end

  def factorial
    Math.factorial(self)
  end

  def double_factorial
    Math.double_factorial(self)
  end

  def factors
    Math.factors(self)
  end

  def factor_array
    Math.factor_array(self)
  end

  def divisors
    Math.divisors(self)
  end

  def enumerate_divisors(proper: false)
    Math.enumerate_divisors(self, proper: proper)
  end

  def enumerate_partitions
    Math.enumerate_integer_partitions(self)
  end

  def count_partitions(max = self)
    Math.count_integer_partitions(self, max)
  end

  def digits(base = 10)
    Math.digits(self, base)
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

  def probably_prime?(sieve_below = 1_299_709, iterations_of_fermat = nil, iterations_of_miller_rabin = nil)
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

  def harshad?
    Math.harshad?(self)
  end

  def right_truncatable_harshad?
    Math.right_truncatable_harshad?(self)
  end

  def strong_harshad?
    Math.strong_harshad?(self)
  end

  def strong_right_truncatable_harshad_prime?
    Math.strong_right_truncatable_harshad_prime?(self)
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

  def legendre_symbol(prime)
    Math.legendre_symbol(self, prime)
  end

  def modular_exponentiation(exponent, modulus)
    Math.modular_exponentiation(self, exponent, modulus)
  end

  def modular_square_roots(prime)
    Math.modular_square_roots(self, prime)
  end

  def root_as_continued_fraction
    Math.root_as_continued_fraction(self)
  end

  def totient
    Math.totient(self)
  end

  def to_byte_string
    Jason::Math::Utility.integer_to_byte_string(self)
  end
end

# Enhancing Rational
class Rational
  def inverse
    Rational(denominator, numerator)
  end
end

# We needed to preserve the existing implmentation
module ArrayExtensions
  def product(*args)
    args.length.positive? ? super(*args) : Math.product(self)
  end
end

# Enhancing Array
class Array
  prepend ArrayExtensions

  def enumerate_partitions
    Math.enumerate_partitions(self)
  end

  def concatenate
    Math.concatenate(self)
  end

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

  def evaluate_continued_fraction(depth = 42)
    Math.evaluate_continued_fraction(self, depth)
  end

  def modular_sum(modulus)
    Math.modular_sum(self, modulus)
  end

  def modular_product(modulus)
    Math.modular_product(self, modulus)
  end
end

# Enhancing Set
class Set
  def co_prime?
    Math.co_prime?(self)
  end

  def pandigital?(initial = 1)
    Math.pandigital?(self, initial)
  end

  def modular_sum(modulus)
    Math.modular_sum(self, modulus)
  end

  def product
    Math.product(self)
  end

  def modular_product(modulus)
    Math.modular_product(self, modulus)
  end
end

# Enhancing Hash
class Hash
  def chinese_remainder_theorem(enforce_co_primality: true)
    Math.chinese_remainder_theorem(self, enforce_co_primality: enforce_co_primality)
  end
end

# Enhancing String
class String
  def byte_string_to_integer
    Jason::Math::Utility.byte_string_to_integer(self)
  end

  def byte_string_to_hex
    Jason::Math::Utility.byte_string_to_hex(self)
  end

  def hex_to_base64
    Jason::Math::Utility.hex_to_base64(self)
  end

  def base64_to_byte_string
    Jason::Math::Utility.base64_to_byte_string(self)
  end

  def byte_string_to_base64
    Jason::Math::Utility.byte_string_to_base64(self)
  end

  def hex_to_byte_string
    Jason::Math::Utility.hex_to_byte_string(self)
  end

  def hex_to_byte_array
    Jason::Math::Utility.hex_to_byte_array(self)
  end

  def ^(other)
    Jason::Math::Utility.xor(self, other)
  end

  def &(other)
    Jason::Math::Utility.and(self, other)
  end

  def |(other)
    Jason::Math::Utility.or(self, other)
  end

  def to_blocks(block_size)
    Jason::Math::Cryptography::Cipher.split_into_blocks(self, block_size)
  end
end

# frozen_string_literal: true

module Jason
  module Math
    module Utility
      # This module is intended to identify data, probabilistically as a given language
      module LanguageDetector
        # this one sums to one, so we need to filter out the punctuation first
        LETTER_FREQUENCIES = {
          english: {
            E: 0.111607,
            A: 0.084966,
            R: 0.075809,
            I: 0.075448,
            O: 0.071635,
            T: 0.069509,
            N: 0.066544,
            S: 0.057351,
            L: 0.054893,
            C: 0.045388,
            U: 0.036308,
            D: 0.033844,
            P: 0.031671,
            M: 0.030129,
            H: 0.030034,
            G: 0.024705,
            B: 0.020720,
            F: 0.018121,
            Y: 0.017779,
            W: 0.012899,
            K: 0.011016,
            V: 0.010074,
            X: 0.002902,
            Z: 0.002722,
            J: 0.001965,
            Q: 0.001962
          }.freeze
        }.freeze

        PUNCTUATION_FREQUENCIES = {
          english: {
            '.': 0.006530,
            ',': 0.006130,
            '"': 0.002670,
            "'": 0.002430,
            '–': 0.001530,
            '?': 0.000560,
            ':': 0.000340,
            '!': 0.000330,
            ';': 0.000320
          }.freeze
        }.freeze

        def self.ordered_search_space(language = :english)
          frequencies = LETTER_FREQUENCIES[language].dup
          punctuation_frequencies = PUNCTUATION_FREQUENCIES[language]
          frequencies.merge!(punctuation_frequencies)

          search_space = [' ', "\n"]
          search_space += frequencies.sort_by { |_symbol, frequency| frequency }.reverse.map do |symbol, _frequency|
            symbol.to_s.downcase
          end

          search_space += search_space.map(&:upcase)
          search_space.uniq!

          search_space += ('0'..'9').to_a

          (0..255).each do |byte|
            character = byte.chr
            search_space << character unless search_space.include?(character)
          end

          search_space
        end

        def self.distance(text, language = :english)
          result = 0.0

          whitespace = "\r\n\t "
          spaces_frequency = text.count(whitespace).to_f / text.length
          result += 0.25 if spaces_frequency < 0.07

          text = text.tr(whitespace, '')

          punctuation_frequencies = PUNCTUATION_FREQUENCIES[language]

          punctuation_frequencies.each_key do |symbol|
            frequency = text.count(symbol.to_s.b).to_f / text.length
            result += (frequency - punctuation_frequencies[symbol]).abs
          end

          punctuation_characters = punctuation_frequencies.keys.map(&:to_s).join
          text = text.tr(punctuation_characters.b, '')

          letter_frequencies = LETTER_FREQUENCIES[language]

          letter_frequencies.each_key do |symbol|
            letter = symbol.to_s
            frequency = text.count(letter + letter.downcase).to_f / text.length
            result += (frequency - letter_frequencies[symbol]).abs
          end

          alphabet = letter_frequencies.keys.map(&:to_s).join
          non_alpha_text = text.tr(alphabet + alphabet.downcase, '')

          result += non_alpha_text.length.to_f / text.length

          result
        end
      end
    end
  end
end

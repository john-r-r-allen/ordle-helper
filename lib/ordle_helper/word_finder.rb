module OrdleHelper
  class WordFinder
    WORD_BANK = "word_bank.csv".freeze
    NOT_INCLUDED_LETTERS = %w().freeze
    CORRECT_LETTERS = {
      0 => "",
      1 => "",
      2 => "",
      3 => "",
      4 => ""
    }.freeze
    INCLUDED_LETTERS_WRONG_SPOT = {
      0 => %w(),
      1 => %w(),
      2 => %w(),
      3 => %w(),
      4 => %w()
    }.freeze

    attr_accessor :word_bank

    def self.word_bank_contains?(word)
      CSV.read(WORD_BANK).map(&:first).include?(word)
    end

    def initialize
      @word_bank = CSV.read(WORD_BANK).map(&:first)
    end

    def call
      exclude_words_with_not_included_letters
      exclude_words_without_correct_letters
      exclude_words_without_included_letters_in_wrong_spot
      output_current_word_bank_state

      true
    end

    def exclude_words_with_not_included_letters
      NOT_INCLUDED_LETTERS.each do |letter|
        word_bank.reject! { |word| word.include?(letter) }
      end
    end

    def exclude_words_without_correct_letters
      CORRECT_LETTERS.each do |position, letter|
        next if letter.empty?

        word_bank.select! { |word| word[position] == letter }
      end
    end

    def exclude_words_without_included_letters_in_wrong_spot
      INCLUDED_LETTERS_WRONG_SPOT.each do |position, letters|
        next if letters.empty?

        letters.each do |letter|
          word_bank.reject! { |word| word[position] == letter }
          word_bank.select! { |word| word.include?(letter) }
        end
      end
    end

    def output_current_word_bank_state
      puts "#{word_bank.size} possible words:"
      return if word_bank.size > 25

      word_bank.each do |word|
        if potential_plural?(word)
          puts "\t#{word} - Potential Plural".yellow
        else
          puts "\t#{word}".blue
        end
      end
    end

    def potential_plural?(word)
      word.end_with?("s")
    end
  end
end

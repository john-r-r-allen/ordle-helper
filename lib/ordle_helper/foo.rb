module OrdleHelper
  class Foo
    WORD_BANK = "word_bank.csv"
    NOT_INCLUDED_LETTERS = %w()
    CORRECT_LETTERS = {
      0 => "",
      1 => "",
      2 => "",
      3 => "",
      4 => ""
    }
    INCLUDED_LETTERS_WRONG_SPOT = {
      0 => %w(),
      1 => %w(),
      2 => %w(),
      3 => %w(),
      4 => %w(),
    }

    attr_accessor :word_bank
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

        word_bank.select! { |word|  word[position] == letter }
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
      if word_bank.size < 25
        word_bank.each do |word|
          puts "\t#{word}"
        end
      end
    end
  end
end

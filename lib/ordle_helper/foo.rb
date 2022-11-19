module OrdleHelper
  class Foo
    WORD_BANK = "word_bank.csv"
    NOT_INCLUDED_LETTERS = %w(r e c h i l d k)
    CORRECT_LETTERS = {
      0 => nil,
      1 => nil,
      2 => "a",
      3 => nil,
      4 => "t"
    }

    attr_accessor :word_bank
    def initialize
      @word_bank = CSV.read(WORD_BANK).map(&:first)
    end

    def call
      exclude_not_included_letters
      exclude_words_without_correct_letters
      binding.pry
      true
    end

    def exclude_not_included_letters
      NOT_INCLUDED_LETTERS.each do |letter|
        word_bank.reject! { |word| word.include?(letter) }
      end
    end

    def exclude_words_without_correct_letters
      CORRECT_LETTERS.each do |position, letter|
        next if letter.nil?
        word_bank.select! { |word|  word[position] == letter }
      end
    end
  end
end

module OrdleHelper
  class WordFinder
    WORD_BANK = "word_bank.csv".freeze

    attr_accessor :word_bank

    def self.word_bank_contains?(word)
      CSV.read(WORD_BANK).map(&:first).include?(word)
    end

    def initialize
      @word_bank = CSV.read(WORD_BANK).map(&:first)
    end

    def call
      verify_consistent_information
      verify_guesses
      exclude_words_with_not_included_letters
      exclude_words_without_correct_letters
      exclude_words_without_included_letters_in_wrong_spot
      output_current_word_bank_state

      true
    end

    def verify_consistent_information
      return if included_letters.empty? || not_included_letters.empty?
      included_letters.each do |included_letter|
        raise "inconsistent information provided" if not_included_letters.include?(included_letter)
      end
    end

    def included_letters
      @included_letters = []
      5.times do |position|
        @included_letters << correct_letters[position] unless correct_letters[position].blank?

        included_letters_wrong_spot[position].each do |word|
          @included_letters << word
        end
      end

      @included_letters
    end

    def verify_guesses
      guesses.each do |guess|
        output = ""
        guess.size.times do |position|
          if not_included_letters.include?(guess[position])
            output += guess[position]
          elsif correct_letters[position] == guess[position]
            output += guess[position].green
          elsif included_letters_wrong_spot[position].include?(guess[position])
            output += guess[position].yellow
          else
            raise RuntimeError, "Letter without information: #{guess[position]}"
          end
        end
        puts output
      end
    end

    def exclude_words_with_not_included_letters
      not_included_letters.each do |letter|
        word_bank.reject! { |word| word.include?(letter) }
      end
    end

    def exclude_words_without_correct_letters
      correct_letters.each do |position, letter|
        next if letter.empty?

        word_bank.select! { |word| word[position] == letter }
      end
    end

    def exclude_words_without_included_letters_in_wrong_spot
      included_letters_wrong_spot.each do |position, letters|
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

    def guesses
      %w()
    end

    def not_included_letters
      %w()
    end

    def correct_letters
      {
        0 => "",
        1 => "",
        2 => "",
        3 => "",
        4 => ""
      }
    end

    def included_letters_wrong_spot
      {
        0 => %w(),
        1 => %w(),
        2 => %w(),
        3 => %w(),
        4 => %w()
      }
    end
  end
end

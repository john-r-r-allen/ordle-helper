module OrdleHelper
  class WordFinder
    WORD_BANK = "word_bank.csv".freeze

    attr_accessor :word_bank

    def self.word_bank_contains?(word)
      CSV.read(WORD_BANK).map(&:first).map(&:upcase).include?(word)
    end

    def initialize
      @word_bank = CSV.read(WORD_BANK).map(&:first)
    end

    def add_guess(word)
      _ = guesses
      _ = correct_letters
      _ = not_included_letters
      _ = included_letters_wrong_spot
      _ = included_letters_with_known_number_of_occurrences
      add_guessed_word(word)
      word.size.times do |position|
        letter = word[position]
        puts "What was the color for #{word[position]} in position #{position + 1}? ".light_blue +
               "Please enter one of the following letters: ".light_blue +
               "\n\t(N)one" +
               "\n\t(Y)ellow".light_yellow +
               "\n\t(G)reen".light_green
        input = gets.chomp.upcase

        case input
        when "G"
          add_to_correct_letters(position:, letter:)
        when "Y"
          add_to_included_letters_wrong_spot(position:, letter:)
        when "N"
          add_to_not_included_letters(letter:, guess: word, position:)
        else
          raise "Invalid response. The only valid responses are 'N', 'Y', and 'G'."
        end

        if correct_letters.values == word.split("") && position == 4
          puts "Great job on getting the correct word of #{word}!".light_green
          return "DONE"
        end
      end
      call
      print_keyboard_state
    end

    def print_keyboard_state
      line_one = "QWERTYUIOP".split("")
      line_two = "ASDFGHJKL".split("")
      line_three = "ZXCVBNM".split("")

      keyboard_state = ""
      line_one.each do |letter|
        if not_included_letters.include?(letter)
          keyboard_state += letter.black
        elsif correct_letters.values.join("").split("").include?(letter)
          keyboard_state += letter.green
        elsif included_letters_wrong_spot.values.join("").split("").include?(letter)
          keyboard_state += letter.yellow
        else
          keyboard_state += letter
        end
        keyboard_state += " "
      end

      keyboard_state += "\n "
      line_two.each do |letter|
        if not_included_letters.include?(letter)
          keyboard_state += letter.black
        elsif correct_letters.values.join("").split("").include?(letter)
          keyboard_state += letter.green
        elsif included_letters_wrong_spot.values.join("").split("").include?(letter)
          keyboard_state += letter.yellow
        else
          keyboard_state += letter
        end
        keyboard_state += " "
      end

      keyboard_state += "\n  "
      line_three.each do |letter|
        if not_included_letters.include?(letter)
          keyboard_state += letter.black
        elsif correct_letters.values.join("").split("").include?(letter)
          keyboard_state += letter.green
        elsif included_letters_wrong_spot.values.join("").split("").include?(letter)
          keyboard_state += letter.yellow
        else
          keyboard_state += letter
        end
        keyboard_state += " "
      end

      puts keyboard_state
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
        raise "Inconsistent information provided." if not_included_letters.include?(included_letter)
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
            output += guess[position].light_green
          elsif included_letters_wrong_spot[position].include?(guess[position])
            output += guess[position].light_yellow
          else
            raise "Letter without information: #{guess[position]}." unless included_letters_with_known_number_of_occurrences.key?(guess[position])

            if included_letters_with_known_number_of_occurrences[guess[position]] < guess.split("").count(guess[position])
              output += guess[position]
            else
              raise "Unknown error occurred."
            end
          end
        end
        puts output
      end
    end

    def exclude_words_with_not_included_letters
      not_included_letters.each do |letter|
        word_bank.reject! { |word| word.upcase.include?(letter.upcase) }
      end
    end

    def exclude_words_without_correct_letters
      correct_letters.each do |position, letter|
        next if letter.empty?

        word_bank.select! { |word| word[position].upcase == letter.upcase }
      end
    end

    def exclude_words_without_included_letters_in_wrong_spot
      included_letters_wrong_spot.each do |position, letters|
        next if letters.empty?

        letters.each do |letter|
          word_bank.reject! { |word| word[position].upcase == letter.upcase }
          word_bank.select! { |word| word.upcase.include?(letter.upcase) }
        end
      end
    end

    def output_current_word_bank_state
      puts "#{word_bank.size} possible words:"
      return if word_bank.size > 25

      word_bank.each do |word|
        if potential_plural?(word)
          puts "\t#{word} - Potential Plural".light_yellow
        else
          puts "\t#{word}".light_cyan
        end
      end
    end

    def potential_plural?(word)
      word.end_with?("s")
    end

    def guesses
      @guesses ||= []
    end

    def add_guessed_word(word)
      @guesses << word

      puts "Added guess of #{word}.".light_green
    end

    def not_included_letters
      @not_included_letters ||= []
    end

    def add_to_not_included_letters(letter:, guess:, position:)
      return if not_included_letters.include?(letter)
      if guess.split("").count(letter) > 1 && guess[0..position - 1].include?(letter)
        return add_occurrence_limit(letter:, guess:, position:)
      end

      @not_included_letters << letter
    end

    def add_occurrence_limit(letter:, guess:, position:)
      valid_number_of_occurrences = 0
      position.times do |i|
        valid_number_of_occurrences += 1 if guess[i] == letter
      end
      @included_letters_with_known_number_of_occurrences[letter] = valid_number_of_occurrences
      puts "Set occurrence limit for #{letter} to #{valid_number_of_occurrences}".light_green
    end

    def correct_letters
      @correct_letters ||= {
        0 => "",
        1 => "",
        2 => "",
        3 => "",
        4 => ""
      }
    end

    def add_to_correct_letters(position:, letter:)
      return if @correct_letters[position] == letter
      raise "Attempting to set a new correct letter in position #{position + 1}." unless correct_letters[position].blank?

      @correct_letters[position] = letter
    end

    def included_letters_wrong_spot
      @included_letters_wrong_spot ||= {
        0 => %w(),
        1 => %w(),
        2 => %w(),
        3 => %w(),
        4 => %w()
      }
    end

    def add_to_included_letters_wrong_spot(position:, letter:)
      @included_letters_wrong_spot[position] << letter
    end

    def included_letters_with_known_number_of_occurrences
      @included_letters_with_known_number_of_occurrences ||= {
      }
    end
  end
end

module OrdleHelper
  class WordFinder # rubocop:disable Metrics/ClassLength
    WORD_BANK = "word_bank.csv".freeze
    GUESSED_CORRECT_WORD = "GGGGG".freeze

    attr_accessor :word_bank

    def self.word_bank_contains?(word)
      CSV.read(WORD_BANK).map(&:first).map(&:upcase).include?(word)
    end

    def initialize
      @word_bank = CSV.read(WORD_BANK).map(&:first)
    end

    def add_guess(word:, game_number: 1) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      _ = guesses
      _ = correct_letters
      _ = not_included_letters
      _ = included_letters_wrong_spot
      _ = included_letters_with_known_number_of_occurrences
      add_guessed_word(word)
      # rubocop:disable Style/StringConcatenation
      puts "What was the colors for #{word} in game #{game_number}?".light_blue +
           "\nPlease enter one of the following letters for each letter in the word ".light_blue +
           "(Example: ".light_blue + "NNN" + "G".light_green + "N" + "):".light_blue +
           "\n\t(N)one" +
           "\n\t(Y)ellow".light_yellow +
           "\n\t(G)reen".light_green
      # rubocop:enable Style/StringConcatenation
      inputs = gets.chomp.upcase

      if inputs == GUESSED_CORRECT_WORD
        puts "Great job on getting the correct word of #{word}!".light_green
        return "DONE"
      end

      inputs.split("").each_with_index do |input, position|
        case input
        when "G"
          add_to_correct_letters(position:, letter: word[position])
        when "Y"
          add_to_included_letters_wrong_spot(position:, letter: word[position])
        when "N"
          add_to_not_included_letters(letter: word[position], guess: word, position:)
        else
          raise "Invalid response. The only valid responses are 'N', 'Y', and 'G'."
        end
      end
      call
      print_keyboard_state
    end

    def print_keyboard_state # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      line_one = "QWERTYUIOP".split("")
      line_two = "ASDFGHJKL".split("")
      line_three = "ZXCVBNM".split("")

      keyboard_state = ""
      line_one.each do |letter|
        keyboard_state += if not_included_letters.include?(letter)
                            letter.black
                          elsif correct_letters.values.join("").split("").include?(letter)
                            letter.green
                          elsif included_letters_wrong_spot.values.join("").split("").include?(letter)
                            letter.yellow
                          else
                            letter
                          end
        keyboard_state += " "
      end

      keyboard_state += "\n "
      line_two.each do |letter|
        keyboard_state += if not_included_letters.include?(letter)
                            letter.black
                          elsif correct_letters.values.join("").split("").include?(letter)
                            letter.green
                          elsif included_letters_wrong_spot.values.join("").split("").include?(letter)
                            letter.yellow
                          else
                            letter
                          end
        keyboard_state += " "
      end

      keyboard_state += "\n  "
      line_three.each do |letter|
        keyboard_state += if not_included_letters.include?(letter)
                            letter.black
                          elsif correct_letters.values.join("").split("").include?(letter)
                            letter.green
                          elsif included_letters_wrong_spot.values.join("").split("").include?(letter)
                            letter.yellow
                          else
                            letter
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

    def verify_guesses # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
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
            unless included_letters_with_known_number_of_occurrences.key?(guess[position])
              raise "Letter without information: #{guess[position]}."
            end

            unless included_letters_with_known_number_of_occurrences[guess[position]] < guess.split("").count(guess[position]) # rubocop:disable Layout/LineLength
              raise "Unknown error occurred."
            end

            output += guess[position]

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

        word_bank.select! { |word| word[position].casecmp(letter).zero? }
      end
    end

    def exclude_words_without_included_letters_in_wrong_spot
      included_letters_wrong_spot.each do |position, letters|
        next if letters.empty?

        letters.each do |letter|
          word_bank.reject! { |word| word[position].casecmp(letter).zero? }
          word_bank.select! { |word| word.upcase.include?(letter.upcase) }
        end
      end
    end

    def output_current_word_bank_state
      puts "#{word_bank.size} possible words:"
      return if word_bank.reject { |word| potential_plural?(word) }.count > 10 # rubocop:disable Performance/Count

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

      unless correct_letters[position].blank?
        puts "Attempting to set a new correct letter in position #{position + 1}.".red +
             "\nAttemping to set letter #{letter} where #{@correct_letters[position]} is already set.".red
        raise "Attempted to set new letter as correct for given position. Failing."
      end

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
      @included_letters_with_known_number_of_occurrences ||= {}
    end
  end
end

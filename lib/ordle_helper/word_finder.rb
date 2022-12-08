module OrdleHelper
  class WordFinder # rubocop:disable Metrics/ClassLength
    WORD_BANK = "word_bank.csv".freeze
    GUESSED_CORRECT_WORD = "GGGGG".freeze
    CORRECT_LETTER = "G".freeze
    RIGHT_LETTER_WRONG_SPOT = "Y".freeze
    NOT_INCLUDED_LETTER = "N".freeze

    attr_accessor :input,
                  :output,
                  :word_bank,
                  :game_word

    def self.word_bank_contains?(word)
      CSV.read(WORD_BANK).map(&:first).map(&:upcase).include?(word)
    end

    def initialize(input: $stdin, output: $stdout)
      @input = input
      @output = output
      @word_bank = CSV.read(WORD_BANK).map(&:first)
      @game_word = OrdleHelper::Word.new
    end

    def add_guess(word:, game_number: 1) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:disable Style/StringConcatenation
      output.puts "What were the colors for #{word} in game #{game_number}?".light_blue +
                  "\nPlease enter one of the following letters for each letter in the word ".light_blue +
                  "(Example: ".light_blue + "NNN" + "G".light_green + "N" + "):".light_blue +
                  "\n\t(N)one" +
                  "\n\t(Y)ellow".light_yellow +
                  "\n\t(G)reen".light_green
      # rubocop:enable Style/StringConcatenation
      inputs = input.gets.chomp.upcase
      if game_word.add_guess(guess: word, guess_feedback: inputs) == "DONE"
        output.puts "Great job on getting the correct word of #{word}!".light_green
        return "DONE"
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
        keyboard_state +=
          if game_word.not_included_letters.include?(letter)
            letter.black
          elsif game_word.correct_letters.values.join("").split("").include?(letter)
            letter.green
          elsif game_word.included_letters_wrong_spot.values.join("").split("").include?(letter)
            letter.yellow
          else
            letter
          end
        keyboard_state += " "
      end

      keyboard_state += "\n "
      line_two.each do |letter|
        keyboard_state +=
          if game_word.not_included_letters.include?(letter)
            letter.black
          elsif game_word.correct_letters.values.join("").split("").include?(letter)
            letter.green
          elsif game_word.included_letters_wrong_spot.values.join("").split("").include?(letter)
            letter.yellow
          else
            letter
          end
        keyboard_state += " "
      end

      keyboard_state += "\n  "
      line_three.each do |letter|
        keyboard_state +=
          if game_word.not_included_letters.include?(letter)
            letter.black
          elsif game_word.correct_letters.values.join("").split("").include?(letter)
            letter.green
          elsif game_word.included_letters_wrong_spot.values.join("").split("").include?(letter)
            letter.yellow
          else
            letter
          end
        keyboard_state += " "
      end

      output.puts keyboard_state
    end

    def call
      verify_guesses
      exclude_words_with_not_included_letters
      exclude_words_without_correct_letters
      exclude_words_without_included_letters_in_wrong_spot
      output_current_word_bank_state

      true
    end

    def verify_guesses # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      game_word.guesses.each do |guess|
        message = ""
        guess.size.times do |position|
          if game_word.not_included_letters.include?(guess[position])
            message += guess[position]
          elsif game_word.correct_letters[position] == guess[position]
            message += guess[position].light_green
          elsif game_word.included_letters_wrong_spot[position].include?(guess[position])
            message += guess[position].light_yellow
          else
            unless game_word.included_letters_with_known_number_of_occurrences.key?(guess[position])
              raise "Letter without information: #{guess[position]}."
            end

            unless game_word.included_letters_with_known_number_of_occurrences[guess[position]] < guess.split("").count(guess[position]) # rubocop:disable Layout/LineLength
              raise "Unknown error occurred."
            end

            message += guess[position]

          end
        end
        output.puts message
      end
    end

    def exclude_words_with_not_included_letters
      game_word.not_included_letters.each do |letter|
        word_bank.reject! { |word| word.upcase.include?(letter.upcase) }
      end
    end

    def exclude_words_without_correct_letters
      game_word.correct_letters.each do |position, letter|
        next if letter.empty?

        word_bank.select! { |word| word[position].casecmp(letter).zero? }
      end
    end

    def exclude_words_without_included_letters_in_wrong_spot
      game_word.included_letters_wrong_spot.each do |position, letters|
        next if letters.empty?

        letters.each do |letter|
          word_bank.reject! { |word| word[position].casecmp(letter).zero? }
          word_bank.select! { |word| word.upcase.include?(letter.upcase) }
        end
      end
    end

    def output_current_word_bank_state # rubocop:disable Metrics/AbcSize
      output.puts "#{word_bank.size} possible words:"
      return if word_bank.reject { |word| potential_plural?(word) }.count > 10 # rubocop:disable Performance/Count

      word_bank.each do |word|
        if potential_plural?(word)
          output.puts "\t#{word} - Potential Plural".light_yellow
        else
          output.puts "\t#{word}".light_cyan
        end
      end
    end

    def potential_plural?(word)
      word.end_with?("s")
    end

    def add_occurrence_limit(letter:, guess:)
      valid_number_of_occurrences = 0
      guess.size.times do |i|
        valid_number_of_occurrences += 1 if guess[i] == letter
      end
      @included_letters_with_known_number_of_occurrences[letter] = valid_number_of_occurrences
      output.puts "Set occurrence limit for #{letter} to #{valid_number_of_occurrences}".light_green
    end

    def add_to_correct_letters(position:, letter:)
      return if @correct_letters[position] == letter

      unless correct_letters[position].blank?
        output.puts "Attempting to set a new correct letter in position #{position + 1}.".red +
                    "\nAttemping to set letter #{letter} where #{@correct_letters[position]} is already set.".red
        raise "Attempted to set new letter as correct for given position. Failing."
      end

      @correct_letters[position] = letter
    end

    def add_to_included_letters_wrong_spot(position:, letter:)
      @included_letters_wrong_spot[position] << letter
    end
  end
end

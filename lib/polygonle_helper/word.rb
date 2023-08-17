module PolygonleHelper
  class Word # rubocop:disable Metrics/ClassLength
    CORRECT_LETTER = "G".freeze
    RIGHT_LETTER_WRONG_SPOT = "Y".freeze
    NOT_INCLUDED_LETTER = "N".freeze
    GUESSED_CORRECT_WORD = "GGGGGGGG".freeze
    RESET_CORRECT_LETTER_ERROR = "Attempting to reset correct letter to new value".freeze
    WORD_SIZE = 8

    attr_reader :guesses,
                :not_included_letters,
                :correct_letters,
                :included_letters_wrong_spot,
                :known_letter_occurrences

    def initialize
      @guesses = []
      @not_included_letters = []
      @correct_letters = {
        0 => "",
        1 => "",
        2 => "",
        3 => "",
        4 => "",
        5 => "",
        6 => "",
        7 => ""
      }
      @included_letters_wrong_spot = {
        0 => %w(),
        1 => %w(),
        2 => %w(),
        3 => %w(),
        4 => %w(),
        5 => %w(),
        6 => %w(),
        7 => %w()
      }
      @known_letter_occurrences = {}
    end

    def add_guess(guess:, guess_feedback:)
      raise "Incomplete guess feedback" unless guess_feedback.size == WORD_SIZE
      return "DONE" if guess_feedback == GUESSED_CORRECT_WORD

      @guesses << guess
      handle_multiple_letter_occurrences(guess:, guess_feedback:) if guess_contains_duplicated_letters?(guess)
      guess_feedback.split("").each_with_index do |feedback, index|
        process_feedback(guess:, feedback:, index:)
      end

      verify_consistent_information
    end

    def guess_contains_duplicated_letters?(guess)
      guess.split("").tally.values.max != 1
    end

    def handle_multiple_letter_occurrences(guess:, guess_feedback:) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      guess_array = guess.split("")
      guess_array.each_with_index do |letter, index|
        next if guess_array.tally[letter] == 1
        next unless guess_array.index(letter) == index # only take action on first instance of the letter

        position_and_feedback = { index => guess_feedback[index] }
        ((index + 1)..WORD_SIZE).each do |i|
          position_and_feedback[i] = guess_feedback[i] if guess[i] == letter
        end
        next if position_and_feedback.values.uniq.size == 1 # no action for all the same feedback
        next if position_and_feedback.values.uniq.sort == %w(G Y)
        next if known_letter_occurrences.key?(letter)

        @known_letter_occurrences[letter] =
          position_and_feedback.reject { |_position, feedback| feedback == "N" }.count # rubocop:disable Performance/Count
      end
    end

    def process_feedback(guess:, feedback:, index:)
      case feedback
      when CORRECT_LETTER
        add_to_correct_letters(guess:, index:)
      when RIGHT_LETTER_WRONG_SPOT
        add_to_included_letters_wrong_spot(guess:, index:)
      when NOT_INCLUDED_LETTER
        add_to_not_included_letters(guess:, index:)
      else
        raise "Invalid response. The only valid responses are 'N', 'Y', and 'G'."
      end
    end

    def add_to_correct_letters(guess:, index:)
      raise RESET_CORRECT_LETTER_ERROR unless correct_letters[index].empty? || correct_letters[index] == guess[index]

      @correct_letters[index] = guess[index]
    end

    def add_to_included_letters_wrong_spot(guess:, index:)
      return if included_letters_wrong_spot[index].include?(guess[index])

      @included_letters_wrong_spot[index] << guess[index]
    end

    def add_to_not_included_letters(guess:, index:)
      return if not_included_letters.include?(guess[index])
      return if known_letter_occurrences.key?(guess[index])

      @not_included_letters << guess[index]
    end

    def verify_consistent_information
      return if included_letters.empty? || not_included_letters.empty?

      included_letters.each do |letter|
        next if known_letter_occurrences.key?(letter)

        raise "Inconsistent information provided." if not_included_letters.include?(letter)
      end
    end

    def included_letters
      @included_letters = []

      WORD_SIZE.times do |position|
        @included_letters << correct_letters[position] unless correct_letters[position].blank?

        included_letters_wrong_spot[position].each do |word|
          @included_letters << word
        end
      end
      @included_letters.uniq!

      @included_letters
    end
  end
end

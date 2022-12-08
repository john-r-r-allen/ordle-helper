module OrdleHelper
  class Word
    CORRECT_LETTER = "G".freeze
    RIGHT_LETTER_WRONG_SPOT = "Y".freeze
    NOT_INCLUDED_LETTER = "N".freeze
    RESET_CORRECT_LETTER_ERROR = "Attempting to reset correct letter to new value".freeze

    attr_reader :guesses, :not_included_letters, :correct_letters, :included_letters_wrong_spot

    def initialize
      @guesses = []
      @not_included_letters = []
      @correct_letters = {
        0 => "",
        1 => "",
        2 => "",
        3 => "",
        4 => ""
      }
      @included_letters_wrong_spot = {
        0 => %w(),
        1 => %w(),
        2 => %w(),
        3 => %w(),
        4 => %w()
      }
    end

    def add_guess(guess:, guess_feedback:)
      handle_multiple_letter_occurences(guess:, guess_feedback:)
      guess_feedback.split("").each_with_index do |feedback, index|
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
    end

    def add_to_correct_letters(guess:, index:)
      raise RESET_CORRECT_LETTER_ERROR unless correct_letters[index].empty? || correct_letters[index] == guess[index]

      @correct_letters[index] = guess[index]
    end

    def add_to_included_letters_wrong_spot(guess:, index:)
      @included_letters_wrong_spot[index] << guess[index] unless included_letters_wrong_spot[index].include?(guess[index])
    end

    def add_to_not_included_letters(guess:, index:)
      @not_included_letters << guess[index] unless not_included_letters.include?(guess[index])
    end
  end
end

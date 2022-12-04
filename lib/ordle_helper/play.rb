module OrdleHelper
  class Play
    MAX_NUMBER_OF_TURNS = 13
    EXIT_WORDS = %w(DONE QUIT EXIT STOP).freeze
    MESSAGES = {
      GAME_SELECTION: "Which ordle game are you playing? Please enter one of the following letters:".light_blue +
        "\n\t(W)ordle" +
        "\n\t(Q)uordle" +
        "\n\t(O)ctordle",
      GAME_START: "Initiating word finder.".light_blue,
      GUESS_PROMPT: "Enter your guess. If you would like to exit, type 'done' and press Enter/Return.".light_blue
    }.freeze

    attr_reader :input, :output, :games, :finished_games

    def initialize(input: $stdin, output: $stdout)
      @input = input
      @output = output
      @games = []
      @finished_games = []
    end

    def determine_and_initiate_game
      output.puts MESSAGES[:GAME_SELECTION]
      user_input = input.gets.chomp.upcase
      case user_input
      when "W"
        call
      when "Q"
        call(4)
      when "O"
        call(8)
      else
        raise "#{user_input} is not a valid response."
      end
    end

    def call(game_instances = 1)
      output.puts MESSAGES[:GAME_START]
      game_instances.times { |i| games[i] = OrdleHelper::WordFinder.new }

      MAX_NUMBER_OF_TURNS.times do |_turn|
        output.puts MESSAGES[:GUESS_PROMPT]
        user_input = gets.chomp.upcase
        break if EXIT_WORDS.include?(user_input)

        raise "#{user_input} is not a valid word" unless OrdleHelper::WordFinder.word_bank_contains?(user_input)
        add_guess_to_games(user_input)
        break if all_games_completed?
      end
    end

    def add_guess_to_games(word)
      games.each_with_index do |game, index|
        next if finished_games.include?(game)
        game_number = index + 1

        finished_games << game if game.add_guess(word:, game_number:) == "DONE"
      end
    end

    def all_games_completed?
      games.size == finished_games.size
    end
  end
end

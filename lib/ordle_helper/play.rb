module OrdleHelper
  class Play
    MAX_NUMBER_OF_TURNS = 13

    attr_accessor :guess_number

    def initialize
      @guess_number = 0
    end

    def determine_and_initiate_game
      puts "Which ordle game are you playing? ".light_blue +
             "Please Enter one of the following letters:".light_blue +
             "\n\t(W)ordle" +
             "\n\t(Q)uordle" +
             "\n\t(O)ctordle"
      input = gets.chomp.upcase
      case input
      when "W"
        call
      when "Q"
        call(4)
      when "O"
        call(8)
      else
        raise "#{input} is not a valid response."
      end
    end

    def call(game_instances = 1)
      puts "Initiating word finder.".light_blue
      games = []
      game_instances.times { |i| games[i] = OrdleHelper::WordFinder.new }
      finished_games = []

      MAX_NUMBER_OF_TURNS.times do |_turn|
        puts "Enter your guess. If you would like to exit, type 'done' and press Enter/Return.".light_blue
        input = gets.chomp.upcase
        return if %w(DONE QUIT EXIT STOP).include?(input)
        raise "#{input} is not a valid word" unless OrdleHelper::WordFinder.word_bank_contains?(input)

        games.each_with_index do |game, index|
          next if finished_games.include?(game)

          finished_games << game if game.add_guess(word: input, game_number: index + 1) == "DONE"
        end

        return if games.size == finished_games.size
      end
    end
  end
end

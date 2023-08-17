module PolygonleHelper
    class Play
        MAX_NUMBER_OF_TURNS = 500
        EXIT_WORDS = %w(DONE QUIT EXIT STOP).freeze
        MESSAGES = {
          GAME_START: "Initiating word finder.".light_blue,
          GUESS_PROMPT: "Enter your guess. If you would like to exit, type 'done' and press Enter/Return.".light_blue
        }.freeze

        attr_reader :input, :output
    
        def initialize(input: $stdin, output: $stdout)
          @input = input
          @output = output
        end

        def call()
          output.puts MESSAGES[:GAME_START]
          game = PolygonleHelper::WordFinder.new
    
          MAX_NUMBER_OF_TURNS.times do |_turn|
            output.puts MESSAGES[:GUESS_PROMPT]
            user_input = input.gets.chomp.upcase
            break if EXIT_WORDS.include?(user_input)
    
            raise "#{user_input} is not a valid word." unless PolygonleHelper::WordFinder.word_bank_contains?(user_input)
    
            game.add_guess(word: user_input)
          end
        end
    end
end

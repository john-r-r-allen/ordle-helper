module OrdleHelper
  class Play
    MAX_NUMBER_OF_TURNS = 13

    attr_accessor :guess_number
    attr_reader :word_finder

    def initialize
      @guess_number = 0
      @word_finder = OrdleHelper::WordFinder.new
    end

    def call
      puts "Initiating word finder.".light_blue
      MAX_NUMBER_OF_TURNS.times do |_turn|
        puts "Enter your guess. If you would like to exit, type 'done' and press Enter/Return.".light_blue
        input = gets.chomp.upcase
        return if %w(DONE QUIT EXIT STOP).include?(input)
        raise "#{input} is not a valid word" unless OrdleHelper::WordFinder.word_bank_contains?(input)

        return_value = word_finder.add_guess(input)
        return if return_value == "DONE"
      end
    end
  end
end

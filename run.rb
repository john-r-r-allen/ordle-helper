require_relative "lib/ordle_helper"

winning_words = OrdleHelper::WinningWord.new
new_winners = ENV["WINNING_WORDS"]&.split&.compact || []
new_winners.each do |winner|
  winning_words.add_winner(winner)
end
winning_words.print_winners if ENV["PRINT_WINNERS"] == "1"

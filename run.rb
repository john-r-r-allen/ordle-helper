require_relative "lib/ordle_helper"


play = OrdleHelper::Play.new
play.determine_and_initiate_game
# play.call
#
# winning_words = OrdleHelper::WinningWord.new
# remove_winners = ENV["REMOVE_WINNING_WORDS"]&.split&.compact || []
# remove_winners.each do |winner_to_remove|
#   winning_words.remove_winner(winner_to_remove)
# rescue StandardError => e
#   puts e.message.red
# end
# new_winners = ENV["WINNING_WORDS"]&.split&.compact || []
# new_winners.each do |winner|
#   winning_words.add_winner(winner)
# rescue StandardError => e
#   puts e.message.red
# end
# winning_words.print_winners if ENV["PRINT_WINNERS"] == "1"

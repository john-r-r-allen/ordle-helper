require "active_support/all"
require "csv"
require "dotenv"
Dotenv.load(".env")
require "pry"
require_relative "ordle_helper/word_finder"
require_relative "ordle_helper/winning_word"

module OrdleHelper
end

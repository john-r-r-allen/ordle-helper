require "active_support/all"
require "colorize"
require "csv"
require "dotenv"
Dotenv.load(".env")
require "stringio"
require "pry"
require_relative "ordle_helper/word_finder"
require_relative "ordle_helper/winning_word"
require_relative "ordle_helper/play"

module OrdleHelper
end

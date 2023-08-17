require "active_support/all"
require "colorize"
require "csv"
require "dotenv"
Dotenv.load(".env")
require "stringio"
require "pry"

require_relative "polygonle_helper/play"
require_relative "polygonle_helper/word"
require_relative "polygonle_helper/word_finder"

module PolygonleHelper
end

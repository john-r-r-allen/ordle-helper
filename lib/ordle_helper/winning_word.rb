module OrdleHelper
  class WinningWord
    WINNING_WORDS_FILE = "winning_words.csv".freeze
    CSV_READ_OPTIONS = { headers: true }.freeze
    CSV_WRITE_OPTIONS = {}.freeze

    attr_accessor :winning_words

    def initialize
      @winning_words = {}
      winning_words_file.each do |row|
        data = row.to_h.deep_symbolize_keys
        @winning_words[data[:word]] = data[:wins].to_i
      end
    end

    def winning_words_file
      @winning_words_file ||= CSV.read(WINNING_WORDS_FILE, CSV_READ_OPTIONS)
    end

    def add_winner(winning_word)
      if winning_words.has_key?(winning_word)
        winning_words[winning_word] = winning_words[winning_word] + 1
      else
        winning_words[winning_word] = 1
      end

      save_to_winning_words_file
    end

    def save_to_winning_words_file
      file_contents =  CSV.generate do |csv|
        csv << %w(word wins)
        winning_words.each do |winning_word|
          csv << winning_word
        end
      end
      File.open(WINNING_WORDS_FILE, 'w') { |f| f.write(file_contents) }
    end

    def print_winners
      puts "Winning words"
      winning_words.each do |word, wins|
        puts "\t#{word} has #{wins} win#{wins == 1  ? "": "s"}"
      end
    end
  end
end

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

    def add_winner(word)
      raise RuntimeError, invalid_winner_message(word) unless WordFinder.word_bank_contains?(word)

      if winning_words.has_key?(word)
        winning_words[word] = winning_words[word] + 1
      else
        winning_words[word] = 1
      end
      puts "Added winning word: #{word}".green

      save_to_winning_words_file
    end

    def remove_winner(word)
      raise RuntimeError, invalid_removal_message(word) unless winning_words.include?(word)

      if winning_words[word] <= 1
        winning_words.delete(word)
      else
        winning_words[word] -= 1
      end
      puts "removed winning word #{word}".green

      save_to_winning_words_file
    end

    def invalid_removal_message(word)
      "Unable to remove #{word} from winners list as it has never won"
    end

    def invalid_winner_message(winning_word)
      "Unable to add winning word #{winning_word} as it does not exist in the word bank."
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

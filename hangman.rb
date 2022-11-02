module LoadIntroFiles
  attr_reader :words, :words_filtered
  
  def load_english_words_file
    @words_file = File.open('google-10000-english-no-swears.txt', 'r')
    @words = []
    until words_file.eof?
    words.push(@words_file.readline)
    end
    filter_words_for_length()
  end

  def filter_words_for_length
    @words_filtered = words.filter do |word|
      word.strip.length >= 5
    end
    puts words_filtered
  end
end

class Player
  def initialize()
    puts "Enter your Player Name:"
    @name = gets.chomp.capitalize
  end
end

class ComputerPlayer
  include LoadIntroFiles

  def random_word_generator
    random_index = rand(words_filtered.length)
    comp_word_guess = words_filtered[random_index]
    puts comp_word_guess
    comp_word_guess
  end
end

class Game
  include LoadIntroFiles

  def initialize()
    @player = Player.new
    load_game()
  end

  def load_game
    load_english_words_file()
    @computer_word_guess = ComputerPlayer.new.random_word_generator
    # resume here
  end
end

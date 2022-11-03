module Messages
  def ask_player_name
    'Enter your player name:'
  end

  def new_line
    "\n"
  end

  def greeting(player)
    puts new_line()
    puts "Welcome #{player} to Hangman!"
  end

  def pick_letter
    puts "Pick one letter as your guess to find the word"
  end
end

module LoadIntroFiles
  attr_reader :words, :words_filtered
  
  def load_english_words_file
    @words_file = File.open('google-10000-english-no-swears.txt', 'r')
    @words = []
    until @words_file.eof?
    words.push(@words_file.readline)
    end
    filter_words_for_length()
  end

  def filter_words_for_length
    @words_filtered = words.filter do |word|
      word.strip.length >= 5
    end
    words_filtered
  end
end

class Player
  include Messages

  attr_accessor :player_guess_new_array

  def initialize()
    puts ask_player_name()
    @name = gets.chomp.capitalize
    greeting(@name)
  end

  def player_guess_array(word_answer)
    @word_answer_length = word_answer.length
    @player_guess_new_array = Array.new(@word_answer_length).map {|letter| letter = "_" }
    puts "The word you should guess has #{@word_answer_length} letters:"
    puts @player_guess_new_array
  end

  def player_guess(word_answer_array)
    pick_letter()
    @player_guess_letter = gets.chomp.upcase
    word_answer_array.each_with_index do |letter_answer, index_answer|
      if letter_answer == @player_guess_letter
        player_guess_new_array[index_answer] = letter_answer
      end
    end
    puts player_guess_new_array
  end
end

class ComputerPlayer
  include LoadIntroFiles
  
  def random_word_generator(words)
    @random_index = rand(words.length)
    @comp_word_guess = words[@random_index].upcase
    puts "This is the random word: #{@comp_word_guess}"
    @comp_word_guess
  end

  def computer_word_to_array(computer_word_guess)
    computer_word_guess.split("")
  end
end

class Game
  include LoadIntroFiles

  attr_reader :player, :computer_word_guess, :computer_word_guess_array

  def initialize()
    @player = Player.new
    load_game()
  end

  def load_game
    @words_array = load_english_words_file()
    @computer_word_guess = ComputerPlayer.new.random_word_generator(@words_array)
    @computer_word_guess_array = @computer_word_guess.split("")
    player_turn(@computer_word_guess, @computer_word_guess_array)
  end

  @@count_guess = 10
  def player_turn(computer_word_guess, computer_word_guess_array)
    puts computer_word_guess
    player.player_guess_array(computer_word_guess)
    player.player_guess(computer_word_guess_array)
  end
  #To Do: count guesses , display guesses more clearly, repeat turns, tell player if no match for interactivity. 
end

def start_game
  Game.new
end

start_game()

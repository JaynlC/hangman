module Messages
  def ask_player_name
    'Enter your player name:'
  end

  def new_line
    puts "\n"
  end

  def greeting(player)
    new_line()
    puts "Welcome #{player} to Hangman!"
  end

  def pick_letter
    puts "Pick one letter as your guess to find the word"
  end

  def display_player_guess(player_guess)
    new_line()
    puts "This is your guess: #{player_guess}"
    new_line()
  end
end

module LoadIntroFiles
  def load_words_dictionary 
    @words_file = File.open('google-10000-english-no-swears.txt', 'r')
    @words = []
    until @words_file.eof?
      @words.push(@words_file.readline)
    end
    filter_words(@words)
  end

  def filter_words(words)
    @word_lengths = 5..12
    words.filter do |word|
      @word_lengths.cover?(word.strip.length)
    end
  end
end

class Player
  include Messages

  attr_accessor :player_guess_letters

  def initialize()
    puts ask_player_name()
    @name = gets.chomp.capitalize
    greeting(@name)
  end

  def player_guess_display_letters(word_answer)
    @word_answer_length = word_answer.strip.length
    @player_guess_letters = Array.new(@word_answer_length).map {|letter| letter = "_" }
    puts "The word you should guess has #{@word_answer_length} letters."
    display_player_guess(player_guess_letters)
  end

  def player_guess(word_answer_array)
    @picked_letter = false
    until @picked_letter
      pick_letter()
      @player_guess_one_letter = gets.chomp.upcase
      if @player_guess_one_letter.length == 1 && @player_guess_one_letter =~ /[A-Za-z]/
        @picked_letter = true
      end
    end
    word_answer_array.each_with_index do |letter_answer, index_answer|
      if letter_answer == @player_guess_one_letter
        player_guess_letters[index_answer] = letter_answer
      end
    end
    # add interactivity for player to get message if no match. 
    display_player_guess(player_guess_letters)
  end

  def return_player_guess
    player_guess_letters
  end
end

class ComputerPlayer
  include LoadIntroFiles

  def random_word_generator(words)
    @random_index = rand(words.length)
    @comp_word_guess = words[@random_index].upcase
    puts "This is the random word: #{@comp_word_guess}" #troubleshooting
    @comp_word_guess
  end

  def computer_word_to_array(computer_word_guess)
    computer_word_guess.split("")
  end
end

class Game
  include LoadIntroFiles

  attr_reader :player, :computer_player, :computer_word_guess, :computer_word_guess_array

  def initialize()
    @player = Player.new
    @computer_player = ComputerPlayer.new
    load_game()
  end

  def load_game
    @words_array = load_words_dictionary()
    @computer_word_guess = computer_player.random_word_generator(@words_array)
    @computer_word_guess_array = computer_player.computer_word_to_array(computer_word_guess);
    player_turn(@computer_word_guess, @computer_word_guess_array)
  end

  def check_win
    @guess = player.return_player_guess
    @win = true
    @guess.each do |letter|
      if letter !~ /[A-Z]/ 
        @win = false
        break
      end
    end
    @win
  end

  @@count_guess = 10
  def player_turn(computer_word_guess, computer_word_guess_array)
    player.player_guess_display_letters(computer_word_guess)
    until @@count_guess == 0 || check_win()
      player.player_guess(computer_word_guess_array)
      @@count_guess -= 1
      puts "Guesses remaining: #{@@count_guess}"
    end
    game_end()
  end

  def game_end
    if @@count_guess == 0
      puts "You Lose"
    elsif @win
      puts "You Win!"
    end 
  end
end

def start_game
  Game.new
end

start_game()

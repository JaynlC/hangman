module Messages
  def ask_player_name
    'Enter your player name:'
  end

  def new_line
    puts "\n"
  end

  def seperator_line
    puts "----------------------------------------------"
  end

  def greeting(player)
    new_line()
    puts "Welcome #{player} to Hangman!"
    new_line()
  end

  def pick_letter
    seperator_line()
    puts "Pick one letter as your guess to find the word"
  end

  def display_player_guess(player_guess)
    new_line()
    puts "This is your guess: #{player_guess}"
  end

  def display_letter_match_message(match_logic, letter)
    new_line()
    if match_logic
      puts "#{letter} is a Match! Well done"
    else puts "#{letter} is not a match!"
    end
  end

  def display_guesses_remaining(number)
    new_line()
    puts "Guesses remaining: #{number}"
  end

  def display_all_guesses(guesses)
    new_line()
    puts "Guesses so far: #{guesses}"
  end

  def display_new_game_option
    new_line()
    seperator_line()
    puts "Please type 'R' to restart the game, or 'N' to end the game."
  end

  def end_game_message(name)
    seperator_line()
    new_line()
    puts "Thank you #{name} for playing Hangman!"
    new_line()
    seperator_line()
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

  attr_accessor :player_guess_letters, :letter_match, :player_letter_choices

  def initialize()
    puts ask_player_name()
    @name = gets.chomp.capitalize
    greeting(@name)
    @player_letter_choices = []
  end

  def player_guess_display_letters(word_answer)
    @word_answer_length = word_answer.strip.length
    @player_guess_letters = Array.new(@word_answer_length).map {|letter| letter = "_" }
    puts "The word you should guess has #{@word_answer_length} letters. Good Luck!"
    display_player_guess(player_guess_letters)
  end

  def player_guess(word_answer_array)
    @picked_letter = false
    until @picked_letter
      pick_letter()
      @player_guess_one_letter = gets.chomp.upcase
      if @player_guess_one_letter.length == 1 && @player_guess_one_letter =~ /[A-Za-z]/
        @player_letter_choices.push(@player_guess_one_letter)
        @picked_letter = true
      end
    end
    check_player_guess(word_answer_array)
  end

  def check_player_guess(word_answer_array)
    @letter_match = false
    word_answer_array.each_with_index do |letter_answer, index_answer|
      if letter_answer == @player_guess_one_letter
        player_guess_letters[index_answer] = letter_answer
        @letter_match = true
      end
    end
    display_letter_match_message(letter_match, @player_guess_one_letter)
    display_all_guesses(@player_letter_choices)
    display_player_guess(player_guess_letters)
  end

  def return_player_guess
    player_guess_letters
  end

  def return_check_letter_match
    letter_match
  end

  def return_name
    @name
  end
end

class ComputerPlayer
  include LoadIntroFiles

  def random_word_generator(words)
    @random_index = rand(words.length)
    @comp_word_guess = words[@random_index].upcase
    @comp_word_guess
  end

  def computer_word_to_array(computer_word_guess)
    computer_word_guess.split("")
  end
end

class Game
  include LoadIntroFiles, Messages

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

  def number_guesses
    @max_guesses = 10
    @@count_guess = @max_guesses
    if @@count_guess == @max_guesses then display_guesses_remaining(@max_guesses) end
  end

  def player_turn(computer_word_guess, computer_word_guess_array)
    player.player_guess_display_letters(computer_word_guess)
    number_guesses()
    until @@count_guess == 0 || check_win()
      player.player_guess(computer_word_guess_array)
      if !(player.return_check_letter_match) then @@count_guess -= 1 end
      display_guesses_remaining(@@count_guess)
    end
    game_end()
  end

  def game_end
    if check_win()
      new_line()
      puts "You Win!"
    elsif @@count_guess == 0
      new_line()
      puts "You Lost, the hidden word was #{@computer_word_guess}"
      puts "Better Luck Next Time!"
    end
    new_game() 
  end

  def new_game
    @option_selected = false
    until @option_selected
      display_new_game_option()
      @new_game_choice = gets.chomp.upcase
      if @new_game_choice == "R"
        initialize()
        @option_selected = true
      elsif @new_game_choice == "N"
       end_game_message(player.return_name())
       @option_selected = true
      end
    end
  end
end

def start_game
  Game.new
end

start_game()

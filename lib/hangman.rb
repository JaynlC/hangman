require 'yaml'

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

  def display_restart_game_option
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
    @words_file = File.open('./google-10000-english-no-swears.txt', 'r')
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

module SaveLoadProgress
  def present_files
    @saved_files = Dir.children('saves')
    files_hash = {}
    @display_saved_files = @saved_files.map.with_index do |filename, index|
      files_hash.store(filename, index + 1)
      "[#{index + 1}] #{filename}"
    end
    puts "This is the list of all files. Pick a file to load."
    puts @display_saved_files
    # puts files_hash
    pick_file(files_hash)
  end

  def deserialise(game_clases)
    YAML::load(game_clases)
    #deserialise specific variables
  end

  def pick_file(files)
    file_selected = false
    until file_selected
      puts "Select the file number you would like to load:"
      load_file_number = gets.chomp.to_i
      if load_file_number !~ /D/
        if load_file_number.between?(1, files.values.last)
          file_selected = true
        end
      end
    end
    filename = files.key(load_file_number)
    puts "#{filename}"
    from_yaml = filename.read #read error here
    deserialise(from_yaml)
  end

  def serialise
    YAML::dump(self)
    #now serialise specific variables I want from game class. See game attributes. 
  end

  def save_game()
    # Dir.mkdir('saves') unless Dir.exists?('saves')
    #need to give user option to create name and save. 
    puts "Enter filename to save:"
    save_filename = gets.chomp
    
    File.open("./saves/#{save_filename}.yaml", "w") do |file|
      file.serialise
    end
    
    # load to start menu.
  end
end

module RandomWordGenerator
  include LoadIntroFiles

  def random_word_generator(words)
    @random_index = rand(words.length)
    words[@random_index].upcase
  end

  def split_word_to_letters(random_word)
    random_word.split("")
  end
end

class Player
  include Messages

  def initialize()
    puts ask_player_name()
    @name = gets.chomp.capitalize
    greeting(@name)
  end

  def return_name
    @name
  end
end

class Game
  include LoadIntroFiles, Messages, SaveLoadProgress, RandomWordGenerator

  attr_reader :player, :random_word, :random_word_array, :player_guess_letters, :letter_match, :player_letter_choices, :picked_save

  def initialize()
    @player = Player.new
    load_game()
  end

  def load_game
    @game_option_selected = false
    until @game_option_selected
      puts "Select '1' to load saved game, or '2' to start new game"
      @game_option = gets.chomp.strip
      if @game_option == '1' || @game_option == '2' then @game_option_selected = true end
    end
    if @game_option == '1'
      present_files()
    elsif @game_option == '2' 
      new_game()
    end
  end

  def new_game
    @words_array = load_words_dictionary()
    @random_word = random_word_generator(@words_array)
    @random_word_array = split_word_to_letters(random_word)
    setup_player_display(@random_word)
  end

  def setup_player_display(word_answer)
    @word_answer_length = word_answer.strip.length
    @player_guess_letters = Array.new(@word_answer_length).map {|letter| letter = "_" }
    puts "The word you should guess has #{@word_answer_length} letters. Good Luck!"
    display_player_guess(player_guess_letters)
    @player_letter_choices = []
    player_turn(@random_word_array)
  end

  def number_guesses
    @max_guesses = 10
    @@count_guess = @max_guesses
    if @@count_guess == @max_guesses then display_guesses_remaining(@max_guesses) end
  end

  def check_win
    @guess = player_guess_letters
    @win = true
    @guess.each do |letter|
      if letter !~ /[A-Z]/
        @win = false
        break
      end
    end
    @win
  end

  def player_guess(word_answer_array)
    @picked_letter = false
    @picked_save = false
    until @picked_letter
      pick_letter()
      @player_guess_one_letter = gets.chomp.upcase
      if @player_guess_one_letter.length == 1 && @player_guess_one_letter =~ /[A-Za-z]/
        player_letter_choices.push(@player_guess_one_letter)
        @picked_letter = true
      elsif @player_guess_one_letter == "SAVE"
        @picked_save = true
        @picked_letter = true
      end
    end
    unless @picked_save then check_player_guess(word_answer_array) end
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
    display_all_guesses(player_letter_choices)
    display_player_guess(player_guess_letters)
  end

  def player_turn(random_word_array)
    number_guesses()
    until @@count_guess == 0 || check_win()
      player_guess(random_word_array)
      if picked_save
        save_game()
        break
      elsif !letter_match
        @@count_guess -= 1 
        display_guesses_remaining(@@count_guess)
      else display_guesses_remaining(@@count_guess)
      end
    end
    if @@count_guess == 0 || check_win() then game_end() end
    #What to do when loading back in? Check number of gueses remaining
  end

  def game_end
    if check_win()
      new_line()
      puts "You Win!"
    elsif @@count_guess == 0
      new_line()
      puts "You Lost, the hidden word was #{random_word}"
      puts "Better Luck Next Time!"
    end
    restart_game() 
  end

  def restart_game
    @option_selected = false
    until @option_selected
      display_restart_game_option()
      @restart_game_choice = gets.chomp.upcase
      if @restart_game_choice == "R"
        initialize()
        @option_selected = true
      elsif @restart_game_choice == "N"
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

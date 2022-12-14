require 'yaml'

module Messages
  def new_line
    puts "\n"
  end
  
  def ask_player_name
    new_line()
    'Enter your player name:'
  end

  def seperator_line
    puts "----------------------------------------------"
  end

  def greeting(name = "Player")
    seperator_line()
    new_line()
    puts "Welcome #{name} to Hangman!"
    new_line()
    seperator_line()
  end

  def pick_letter
    seperator_line()
    puts "Pick one letter as your guess to find the word. Or type 'save' to save progress."
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
    puts "Please type 'R' to load or start new game, or 'N' to exit."
  end

  def end_game_message(name)
    seperator_line()
    new_line()
    puts "Thank you #{name} for playing Hangman!"
    new_line()
    seperator_line()
  end

  def win_message
    new_line()
    puts "You Win!"
    new_line()
  end

  def lost_game_message
    new_line()
    puts "You Lost, the hidden word was #{random_word}"
    new_line()
    puts "Better Luck Next Time!"
  end

  def welcome_back(name)
    seperator_line()
    new_line()
    puts "Welcome back #{name} to Hangman!"
    new_line()
    seperator_line()
  end

  def no_saved_files_message(user_mode)
    puts "There are no files to #{user_mode}."
    new_line()
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
  def check_files_exist()
    saved_files = Dir.children('saves')
    files_exist = true
    if saved_files.empty?
      files_exist = false
    end
    files_exist
  end
  
  def present_files(user_mode = 'view_files')
    saved_files = Dir.children('saves')
    files_hash = {}
    @display_saved_files = saved_files.map.with_index do |filename, index|
      files_hash.store(filename, index + 1)
      "[#{index + 1}] #{filename.split(".").first}"
    end
    new_line()
    puts "These are the existing saved files:"
    puts @display_saved_files
    unless user_mode == 'view_files' then pick_file(files_hash, user_mode) end
  end

  def pick_file(files, user_mode)
    file_selected = false
    until file_selected
      puts "Select the file number to #{user_mode}:"
      load_file_number = gets.chomp.to_i
      if load_file_number !~ /D/
        if load_file_number.between?(1, files.values.last)
          file_selected = true
        end
      end
    end
    load_or_delete_file = files.key(load_file_number)
    loop do 
      if user_mode == 'delete'
        delete_file(load_or_delete_file)
        break
      elsif user_mode == 'load'
        load_file(load_or_delete_file, load_file_number)
        break
      end
    end
  end

  def delete_file(delete_file)
    File.delete("./saves/#{delete_file}")
    new_line()
    puts "#{delete_file.split(".").first} has been deleted."
    new_line()
  end

  def deserialise(file_string)
    new_load_file = YAML.load(file_string)
    @name = new_load_file[:name]
    @random_word = new_load_file[:random_word]
    @random_word_array = new_load_file[:random_word_array]
    @player_guess_letters = new_load_file[:player_guess_letters]
    @player_letter_choices = new_load_file[:player_letter_choices]
    @lives = new_load_file[:lives]
  end

  def load_file(file_to_load, file_number)
    File.open("./saves/#{file_to_load}", "r") do |file|
      deserialise(file)
    end
    new_line()
    puts "[#{file_number}] #{file_to_load.split(".").first} saved progress has been loaded..."
  end

  def serialise()
    YAML.dump ({
      :name => player.return_name,
      :random_word => @random_word,
      :random_word_array => @random_word_array,
      :player_guess_letters => @player_guess_letters,
      :player_letter_choices => @player_letter_choices,
      :lives => @lives
    })
  end

  def save_game()
    new_line()
    present_files()
    new_line()
    puts "Enter new filename to save:"
    loop do
      @save_filename = "#{gets.chomp}.YAML"
      current_saves = Dir.children('saves')
      if current_saves.include?(@save_filename)
        puts "This filename exists, please enter new filename:"
      else break
      end
    end
    File.open("./saves/#{@save_filename}", "w") do |file|
      file.write(serialise())
    end
    new_line()
   puts "File has been saved as '#{@save_filename.split(".").first}'"
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
    greeting()
    load_game()
  end

  def load_game
    @game_option_selected = false
    until @game_option_selected
      puts "Select '1' to load saved game, '2' to start new game, or '3' to delete a previous saved game:"
      @game_option = gets.chomp.strip
      if @game_option == '1'
        @user_mode = 'load'
        if check_files_exist()
          present_files(@user_mode)
          welcome_back(@name)
          setup_player_display(@random_word, @game_option)
          @game_option_selected = true
        else
          no_saved_files_message(@user_mode)
        end
      elsif @game_option == '2'
        new_game(@game_option)
        @game_option_selected = true
      elsif @game_option == '3'
        @user_mode = 'delete'
        if check_files_exist()
          present_files(@user_mode)
        else 
          no_saved_files_message(@user_mode)
        end
      end
    end
  end

  def new_game(option_selected)
    @player = Player.new
    @name = player.return_name
    @words_array = load_words_dictionary()
    @random_word = random_word_generator(@words_array)
    @random_word_array = split_word_to_letters(random_word)
    @lives = 10
    @player_letter_choices = []
    setup_player_display(@random_word, option_selected)
  end

  def setup_player_display(word_answer, option_selected)
    @word_answer_length = word_answer.strip.length
    if option_selected == '2'
      @player_guess_letters = Array.new(@word_answer_length).map {|letter| letter = "_" }
    end 
    puts "The word you should guess has #{@word_answer_length} letters. Good Luck!"
    display_player_guess(player_guess_letters)
    display_all_guesses(player_letter_choices)
    display_guesses_remaining(@lives)
    player_turn(@random_word_array)
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
    until @lives == 0 || check_win()
      player_guess(random_word_array)
      if picked_save
        save_game()
        restart_game()
        break
      elsif !letter_match
        @lives -= 1 
        display_guesses_remaining(@lives)
      else display_guesses_remaining(@lives)
      end
    end
    if @lives == 0 || check_win() then game_end() end
  end

  def game_end
    if check_win()
      win_message()
    elsif @lives == 0
      lost_game_message()
    end
    restart_game()
  end

  def restart_game
    loop do
      display_restart_game_option()
      @restart_game_choice = gets.chomp.upcase
      if @restart_game_choice == "R"
        Game.new
        break
      elsif @restart_game_choice == "N"
       end_game_message(@name)
       break
      end
    end
  end
end

def start_game
  Game.new
end

start_game()

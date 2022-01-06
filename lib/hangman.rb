require 'json'

class Hangman
  def initialize
    @hangman_art = File.readlines("hangman-art.txt", "r")[0].gsub("'''", "").split(",")
    @dictionary = File.readlines("dictionary.txt").map(&:chomp)
    @GUESSES = @hangman_art.length - 1
    @wrong_guesses = 0
    @secret_word = random_word(limit_word_length(@dictionary, 5, 12)).downcase
    @current_guess_arr = Array.new(@secret_word.length)
    @current_guess_str = array_to_string(@current_guess_arr)
  end

  def limit_word_length(dictionary, min, max)
    dictionary.select {|word| word.length.between?(min, max)}
  end

  def save_game
    game_state = {wrong_guesses: @wrong_guesses, secret_word: @secret_word, current_guess_arr: @current_guess_arr}
    puts "Please input save filename:"
    File.open("./savedgames/#{gets.chomp}.txt", "w") { |file| file.write game_state.to_json }
  end

  def prompt_save
    puts "Would you like to save and quit? (y/n)"
    loop do
      response = gets.chomp.downcase
      return response if response == "y" || response == "n"
    end
  end

  def load_game(filename)
    game_data = JSON.parse(File.read(filename))
    @wrong_guesses = game_data["wrong_guesses"]
    @secret_word = game_data["secret_word"]
    @current_guess_arr = game_data["current_guess_arr"]
    @current_guess_str = array_to_string(@current_guess_arr)
  end

  def prompt_load
    puts "Would you like to load a previous game? (y/n)"
    response = gets.chomp.downcase
    return unless response == "y"

    puts "Your saved games are:"
    puts Dir.children("./savedgames/")
    puts "Please type the filename of the game you would like to load"
    load_game("./savedgames/#{gets.chomp}")
  end

  def random_word(dictionary)
    dictionary.sample
  end

  def opening_text
    puts "Welcome to Chris's Hangman extravaganza!\n"
    prompt_load
    puts "Let's begin! You will have #{@GUESSES-@wrong_guesses} chances to get the right word\n"+
    "#{@hangman_art[@wrong_guesses]}\n"+
    "#{@current_guess_str}\n"
  end

  def get_user_input
    loop do
      puts "Please input a letter"
      input = gets.chop.downcase
      if input.length == 1 && input.match?(/[a-z]/)
        return input
      else
        puts "#{input} is not a valid input. Please input a letter"
      end
    end
  end

  def array_to_string(array)
    (array.map {|element| element == nil ? "_ " : element}).join("")
  end

  def get_letter_indexes(string, letter)
    (0...string.length).find_all { |i| string[i, 1] == letter }
  end

  def has_won?(array)
    array.none?(nil)
  end

  def play
    opening_text
    loop do
      if !has_won?(@current_guess_arr)
        if @wrong_guesses < @GUESSES
          letter_guess = get_user_input
          if @secret_word.include?(letter_guess)
            letter_indexes = get_letter_indexes(@secret_word, letter_guess)
            letter_indexes.each {|index| @current_guess_arr[index] = letter_guess}
            @current_guess_str = array_to_string(@current_guess_arr)
            puts "Correct! There are #{letter_indexes.length} instances of the letter #{letter_guess}"
          else
            @wrong_guesses += 1
            puts "There are no instances of #{letter_guess} in the secret word\n" + 
            "You have #{@GUESSES-@wrong_guesses} remaining chances"
          end
          puts "#{@hangman_art[@wrong_guesses]}\n#{@current_guess_str}"
          if prompt_save == "y"
            save_game
            return
          end
        else
          puts "Oh no, you have been hung! The correct word was #{@secret_word}. Please try again"
          return
        end
      else
        puts "Congratulations! You live to see another day. Please play again soon!"
        return
      end
    end
  end
end

new_game = Hangman.new
new_game.play
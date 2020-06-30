require 'pry'

#################### DICTIONARY PREVIOUSLY FILTERED #####################
# only contains words at least 6 letter and no more than 12 letter long #

# dictionary = File.readlines "5desk.txt"
# dictionary = dictionary.map { |word| word.strip }.select { |word| word.size <= 12 && word.size >= 6 }
# filename = "5desk_FILTERED.txt"
# File.open(filename, 'w') do |file|
#     file.puts dictionary
# end

class Hangman
    attr_accessor :player, :wins, :games_played
    attr_reader :secret_word, :dictionary

    def initialize(player, turns_per_game, dictionary)
        @player = player
        @wins = 0
        @games_played = 0
        @dictionary = File.readlines dictionary
        @secret_word = ""
        @word_in_progress = ""
        @guessed_letters = []
        @incorrect_letters = []

        @remaining_turns = turns_per_game
        @reset_turns = turns_per_game
        @gap = "  "
        @loser_statements = [
            "Maybe grab a dictionary next time? Just saying...",
            "You do speak English, right?",
            "Ugh, give yourself more turns per game...",
            "You should have read more books as a kid!"
        ]
        @winner_statements = [
            "Yeah, ok... alright, that was just a warm-up.",
            "You're pretty good at the learnedness of words and spelling and, ... good job",
            "I want a re-match, play again! I've got a really tough word this time!",
            "A worthy advisary"
        ]
        clean_dictionary
        start_game
    end

    def play
        while !game_over?
            show_board
            check_save_or_play
            guess_letter
            check_secret_word
        end
        @games_played += 1
        show_board
        complete_game
    end

    def clear_for_new_game
        set_secret_word
        set_word_in_progress
        reset_letters_and_turns
    end

    def start_game
        puts "would you like to load an existing game, or start a new one: LOAD / NEW ?"
        game_type = gets.chomp.upcase
        case game_type
        when "LOAD"
            load_game
        when "NEW"
            clear_for_new_game
            play
        else
            puts "please choose LOAD or NEW "
            start_game
        end
    end

    def show_game_stats
        percentage = (@wins.to_f/@games_played.to_f)
        puts "In this game you have played #{@games_played} times and won #{@wins}. Thats a #{percentage.round(2) * 100}% winning average"
    end

    def set_secret_word
        @secret_word = @dictionary.sample
        @secret_word = @secret_word.upcase
    end

    def reset_letters_and_turns
        @guessed_letters = []
        @incorrect_letters = []
        @remaining_turns = @reset_turns
    end

    def set_word_in_progress
        @word_in_progress = Array.new(@secret_word.size, "_")
    end

    def guess_letter
        puts "Guess a letter..."
        letter = gets.chomp.upcase
        if @guessed_letters.any?(letter)
            puts "You've alredy guessed '#{letter}'..."
            guess_letter
        else
            @guessed_letters << letter
        end
    end

    def check_secret_word
        secret_word = @secret_word.split("")
        current_letter = @guessed_letters.last
        if secret_word.none?(current_letter)
            puts "Aww... sorry... no."
            @incorrect_letters << current_letter
            @remaining_turns -= 1
        else
            secret_word.each_with_index do |letter, index| 
                if letter == current_letter
                    @word_in_progress[index] = current_letter
                end
            end
        end
    end

    def check_save_or_play
        puts "Would you like to play, save and play, or save and quit: PLAY / SAVE / SAVE AND QUIT ?"
        action = gets.chomp.upcase
        case action
        when "SAVE"
            save_game
        when "SAVE AND QUIT"
            save_game
            puts "Goodbye!"
            exit
        when "PLAY"
            return
        else
            puts "please choose PLAY, SAVE, or SAVE AND QUIT"
            check_save_or_play
        end
    end

    def show_board
        puts
        puts "       #{@word_in_progress.join(@gap)}       ||  TURNS REMAINING: #{@remaining_turns}"
        puts
        puts "    USED LETTERS:  #{@incorrect_letters.join(", #{@gap}")}"
    end

    def game_over?
        @word_in_progress.none?("_") || @remaining_turns == 0 ? true : false
    end

    def complete_game
        puts "GAME OVER"
        if @word_in_progress.none?("_")
            puts @winner_statements.shuffle.first
            @wins += 1
        else
            puts @loser_statements.shuffle.last
            puts "The word was: #{@secret_word}"
        end
        show_game_stats

        play_more = "no"
        puts "Want to play again?"
        play_more = gets.chomp.downcase
        if play_more == "yes"
            clear_for_new_game
            play
        else
            puts "Would you like to save your game: YES / NO ?"
            action = gets.chomp.upcase
            if action == "YES"
                save_game
                puts "Goodbye!"
            else
                puts "Goodbye!"
            end
        end
    end
    
    def clean_dictionary
        @dictionary = @dictionary.map { |word| word.strip }
    end

    def save_game
        serialized_game = Marshal::dump(self)

        Dir.mkdir("saved_games") unless Dir.exists? "saved_games"

        puts "file name?"
        filename = gets.chomp
        filename = "saved_games/#{filename}"

        File.open(filename, "w") do |file|
            file.puts serialized_game
        end
    end

    def load_game
        puts "Which game would you like to load?"
        game = gets.chomp
        game = File.read "saved_games/#{game}"

        game = Marshal::load(game)
        game.play
    end
end

game = Hangman.new("Peter", 7, "5desk_FILTERED.txt")


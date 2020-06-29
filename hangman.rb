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
    attr_accessor :player, :wins
    attr_reader :secret_word, :dictionary

    def initialize(player, turns_per_game, dictionary)
        @player = player
        @wins = 0
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
    end

    def play
        set_secret_word
        set_word_in_progress
        reset_letters_and_turns
        
        while !game_over?
            show_board
            guess_letter
            check_secret_word
        end
        show_board
        complete_game
        
    end

    # private

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
        play_more = "no"
        puts "Want to play again?"
        play_more = gets.chomp
        play_more == "yes" ? play : puts("Goodbye!")
    end
    
    def clean_dictionary
        @dictionary = @dictionary.map { |word| word.strip }
    end



end

game = Hangman.new("Peter", 7, "5desk_FILTERED.txt")
game.play


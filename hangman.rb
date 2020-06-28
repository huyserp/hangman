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

    def initialize(player)
        @player = player
        @wins = wins
        @dictionary = File.readlines "5desk_FILTERED.txt"
        @word_to_guess = ""

        set_word_to_guess
    end


end

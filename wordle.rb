#!/usr/bin/env ruby
require 'cgi'
require 'date'
require 'json'
require 'net/http'

MAX_TRIES = 6
WORDS_LIST_URL = 'https://2e6jmolg96.execute-api.us-east-1.amazonaws.com/default/API'

class String
  def green
    "\033[32m#{self}\033[0m"
  end

  def yellow
    "\033[33m#{self}\033[0m"
  end

  def grey
    "\033[37m#{self}\033[0m"
  end

  def black
    "\033[30m#{self}\033[0m"
  end
end

def block_for_color(color)
  case color
  when 'yellow'
    "🟨"
  when 'green'
    "🟩"
  when 'grey'
    "⬜"
  else
    ''
  end
end

class Wordle
  attr_reader :word_of_the_day, :letters
  attr_accessor :tries, :social_share_output, :success

  def initialize
    response  = Net::HTTP.get_response(URI.parse(WORDS_LIST_URL))
    # datestamp = Date.today.to_time.utc.to_i

    @tries = 0
    @success = false
    @social_share_output = ''
    @letters = ('A'..'Z').to_a
    # @word_of_the_day = words[Random.new(datestamp).rand(words.size)].upcase
    @word_of_the_day = response.body.upcase
  end

  def play
    word_of_the_day_letters = word_of_the_day.chars
    puts "Guess the word of the day \nPress Ctrl + C to exit"

    guess = nil
    guessed_letters = []

    while tries < MAX_TRIES && guess != word_of_the_day
      guess = gets.chomp.upcase[0..4]
      guess_chars = guess.chars

      @tries += 1
      output_string = ''
      social_share_string = ''
      guess_chars.each_with_index do |char, index|
        color = 'grey'
        color = 'yellow' if word_of_the_day_letters.include?(char)
        color = 'green' if color == 'yellow' && char == word_of_the_day_letters[index]

        output_string << "#{char} ".send(color)
        social_share_string << "#{block_for_color(color)} "
      end

      social_share_output << "\n#{social_share_string}"

      guessed_letters = (guessed_letters + guess_chars).uniq

      puts output_string
      letters_output = ''
      letters.each do |letter|
        color = 'grey'
        color = 'black' if guessed_letters.include?(letter)
        color = 'yellow' if color == 'black' && word_of_the_day_letters.include?(letter)
        color = 'green' if color == 'yellow' && guess_chars.index(letter) == word_of_the_day_letters.index(letter)

        letters_output << "#{letter} ".send(color)
      end
      puts letters_output
    end

    @success = true if guess == word_of_the_day
  end

  def result
    if success
      puts "You got the correct word in #{tries} guess(es)."
      puts "\n#{social_share_output}\n\n"

      puts "Share with your friends using the link below:\n"
      puts "https://twitter.com/intent/tweet?url=https://deepakmahakale.in/wordle&text=Play%20wordle%20in%20the%20shell.%0A%0AMy%20score%20#{tries}/#{MAX_TRIES}%0A#{CGI.escape(social_share_output)}%0A%0A"
    elsif
      puts 'Better luck next time.'
    end
  end
end

game = Wordle.new
game.play
game.result


# exit 0

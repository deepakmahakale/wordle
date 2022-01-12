#!/usr/bin/env ruby
require 'cgi'
require 'date'
require 'json'
require 'net/http'

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

response = Net::HTTP.get_response(URI.parse('https://deepakmahakale.in/api/words.json'))
words = JSON.parse(response.body)

word_of_the_day = words[Random.new(Date.today.to_time.utc.to_i).rand(words.size)].upcase

word_of_the_day_letters = word_of_the_day.chars
puts "Guess the word of the day \nPress Ctrl + C to exit"

guess = nil
global_output = ''
tries = 0
letters = ('A'..'Z').to_a
guessed_letters = []

while tries < 6 && guess != word_of_the_day
  guess = gets.chomp.upcase[0..4]
  guess_chars = guess.chars

  tries += 1
  output_string = ''
  share_output_string = ''
  guess_chars.each_with_index do |char, index|
    color = 'grey'
    color = 'yellow' if word_of_the_day_letters.include?(char)
    color = 'green' if color == 'yellow' && char == word_of_the_day_letters[index]

    output_string << "#{char} ".send(color)
    share_output_string << "#{block_for_color(color)} "
  end

  global_output << "\n#{share_output_string}"

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

if(guess == word_of_the_day)
  puts "You got the correct word in #{tries} guess(es)."
  puts "\n#{global_output}\n\n"

  puts "Share with your friends using the link below:\n"
  puts "https://twitter.com/intent/tweet?url=https://deepakmahakale.in/wordle&text=Play%20wordle%20in%20the%20shell.%0A%0AMy%20score%20#{tries}/6%0A#{CGI.escape(global_output)}%0A%0A"
elsif tries >= 6
  puts 'Better luck next time.'
end

# exit 0

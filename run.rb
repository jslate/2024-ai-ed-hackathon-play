# frozen_string_literal: true

require './anthropic_chat'

def output(string)
  blue_text = "\e[34m#{string}\e[0m"
  puts
  puts blue_text
  puts
end

debug = ARGV[0].nil? ? false : ARGV[0].downcase == 'debug'

chat = AnthropicChat.new(debug:)

name = chat.ask(template_key: :hello, name: 'Jon', schema: { name: 'string' })['name']
output "#{name} says hello!"

response = chat.ask(message: "What's your favorite color, #{name}? Just pretend you do have one!")
output response

loop do
  print "Prompt: (type 'exit' to quit) "
  user_input = gets.chomp
  break if user_input.downcase == 'exit'

  response = chat.ask(message: user_input)
  output response
end

puts 'Goodbye!'

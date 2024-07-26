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

chat.add_system_messages <<~MSG
  This chat should be about Harry Potter and the Methods or Rationality. Keep gently
  steering the conversation back to that topic.
MSG

name = chat.ask(template_key: :hello, name: 'Jon', schema: { name: 'string' })['name']
output "Hello, #{name}!"

round = 0
loop do
  print "Prompt: (type 'exit' to quit) "
  user_input = gets.chomp
  break if user_input.downcase == 'exit'

  if round % 4 == 0

  else
    response = chat.ask(message: user_input)
    output response
  end
  round += 1
end

puts 'Goodbye!'

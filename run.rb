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
ROUNDS_BETWEEN_QUIZ = 4

assistant_message = <<~MSG
  I'm here to chat with you about Harry Potter and
  the Methods of Rationality. We'll discuss the book,
  its themes, and its characters, and I'll ask you
  every few rounds to see how well you've been paying attention.
MSG

output assistant_message

print 'What aspect of the book would you like to discuss?'
chat.add_assistant_messages([assistant_message])

user_input = gets.chomp
loop do
  break if user_input.downcase == 'q'
  break if round > 10

  # puts "Round: #{round}"
  if round.positive? && (round % ROUNDS_BETWEEN_QUIZ).zero?
    # puts "Quiz Time!"
    response = chat.ask(template_key: :ask_question, number_of_exchanges: 3,
                        schema: { question: 'string' })

    question = response['question']

    output <<~MSG
      ==============================
      Quiz Time!

      Here's a question for you based on our recent exchanges: #{question}
    MSG
  elsif round > 1 && ((round - 1) % ROUNDS_BETWEEN_QUIZ).zero?
    # puts "evaluate_answer!"
    response = chat.ask(
      template_key: :quiz_answer,
      schema: { level_of_engagement: 'A number from 1-10, with 10 being the highest' }
    )

    output "You answered the question with a level of engagement of #{response['level_of_engagement']}."
  else
    # puts "regular chat!"
    response = chat.ask(message: user_input)
    output response
  end

  round += 1

  print "Prompt: (type 'q' to quit) "
  user_input = gets.chomp
end

puts 'Goodbye!'

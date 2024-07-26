# frozen_string_literal: true

require './anthropic_chat'

debug = ARGV[0].nil? ? false : ARGV[0].downcase == 'debug'

chat = AnthropicChat.new(debug:)

name = chat.ask(template_key: :hello, name: 'Jon', schema: { name: 'string' })['name']
puts "#{name} says hello!"

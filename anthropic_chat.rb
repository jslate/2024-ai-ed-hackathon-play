# frozen_string_literal: true

require 'mustache'
require 'aws-sdk-bedrockruntime'
require 'byebug'
require 'active_support/all'


# chat with anthropic!
class AnthropicChat
  attr_reader :messages

  def initialize(debug: false)
    @messages = []
    @debug = debug
  end

  def ask(template_key: nil, message: nil, schema: nil,  **merge_vars)
    raise 'Must provide either a template_key or a message' if template_key.nil? && message.nil?

    if template_key.nil?
      prompt = message
    else
      llm_template = File.read("templates/#{template_key}.mustache")
      prompt = Mustache.render(llm_template, **merge_vars)
    end

    prompt += "Please format your response according to the following schema: #{schema.to_json}" if schema.present?

    add_user_messages(prompt)
    response = chat(@messages, has_schema: schema.present?)
    add_assistant_messages(response)
    response
  end

  def reset
    @messages = []
  end

  def add_user_messages(messages_array)
    add_messages(messages_array, 'user')
  end

  def add_assistant_messages(messages_array)
    add_messages(messages_array, 'assistant')
  end

  def add_system_messages(messages_array)
    add_messages(messages_array, 'system')
  end

  def add_messages(messages_array, role)
    messages_array = [messages_array] unless messages_array.is_a?(Array)
    messages_array.each do |m|
      @messages << { role:, content: m }
    end
  end

  def chat(messages, has_schema: false)
    message_array = messages.map { |m| { role: m[:role], content: m[:content] } }

    # debugger

    if @debug
      puts
      puts JSON.pretty_generate(message_array)
      puts
    end

    request =  {
        model_id: 'anthropic.claude-3-5-sonnet-20240620-v1:0',
        content_type: 'application/json',
        body: {
          messages: message_array,
          anthropic_version: 'bedrock-2023-05-31',
          max_tokens: 50_000,
          # temperature: 0.1,
          # top_k: 20,
          # top_p: 0.20,
          stop_sequences: []
        }.to_json
      }

    if @debug
      puts
      puts JSON.pretty_generate(request)
      puts
    end

    response = client.invoke_model(request)

    response = JSON.parse(response.body.read)
    result = response['content'][0]['text']

    if has_schema
      json = result.split("\n").last
      return JSON.parse(json)
    end

    result
  end

  def client
    @client ||= Aws::BedrockRuntime::Client.new(region: 'us-east-1')
  end
end

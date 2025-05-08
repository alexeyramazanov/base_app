# frozen_string_literal: true

FactoryBot.define do
  factory :chat_message do
    user

    room { 'general' }
    message { 'Hello World!' }
  end
end

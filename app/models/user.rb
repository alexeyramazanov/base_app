# frozen_string_literal: true

class User < ApplicationRecord
  include Authentication

  has_many :chat_messages, dependent: :delete_all
end

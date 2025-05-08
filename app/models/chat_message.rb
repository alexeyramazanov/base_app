# frozen_string_literal: true

class ChatMessage < ApplicationRecord
  ROOMS = %w[general support].freeze

  belongs_to :user

  validates :room, inclusion: { in: ROOMS }
  validates :message, presence: true
end

# frozen_string_literal: true

class ChatMessage < ApplicationRecord
  ROOMS = %w[general support].freeze

  validates :room, inclusion: { in: ROOMS }
  validates :message, presence: true

  belongs_to :user
end

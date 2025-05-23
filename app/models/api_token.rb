# frozen_string_literal: true

class ApiToken < ApplicationRecord
  belongs_to :user

  # TODO: encrypt token
  before_create :generate_token

  def used_now!
    update_column(:last_used_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def generate_token
    self.token = SecureRandom.alphanumeric(32)
  end
end

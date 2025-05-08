# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatMessage do
  describe 'validations' do
    let(:chat_message) { build(:chat_message) }

    it 'validates room inclusion in ROOMS' do
      expect(chat_message).to be_valid

      chat_message.room = 'invalid_room'
      expect(chat_message).not_to be_valid
      expect(chat_message.errors.details[:room]).to include(error: :inclusion, value: 'invalid_room')

      chat_message.room = 'support'
      expect(chat_message).to be_valid
    end

    it 'validates message presence' do
      chat_message.message = nil
      expect(chat_message).not_to be_valid
      expect(chat_message.errors.details[:message]).to include(error: :blank)

      chat_message.message = 'Some message'
      expect(chat_message).to be_valid
    end
  end

  describe 'factories' do
    it 'has a valid factory' do
      chat_message = create(:chat_message)

      expect(chat_message).to be_persisted
    end
  end

  it 'has a predefined list of rooms' do
    expect(described_class::ROOMS).to match_array(%w[general support])
  end
end

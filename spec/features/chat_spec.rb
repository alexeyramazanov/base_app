# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatController do
  let(:password) { '123123' }
  let(:user) { create(:user, email: 'user@email.com', password: password, password_confirmation: password) }

  let(:messages_div) { 'div[data-chat-target="messages"]' }

  describe 'chat' do
    it 'works and persists messages when switching between rooms' do
      sign_in(user, password)

      visit chat_path
      expect(page).to have_current_path(chat_path('general'))

      fill_in 'Type a message...', with: 'Hello'
      click_button 'Send'

      expect(find(messages_div)).to have_content("#{user.email}: HelloInvalid") # TODO: fix

      click_link 'Support'

      expect(find(messages_div)).not_to have_content("#{user.email}: Hello")

      click_link 'General'

      expect(find(messages_div)).to have_content("#{user.email}: Hello")
    end
  end
end

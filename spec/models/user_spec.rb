# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'concerns' do
    it 'includes Authentication concern' do
      expect(described_class.ancestors).to include(Authentication)
    end
  end

  describe 'associations' do
    it 'deletes associated chat_messages when destroyed' do
      user = create(:user)
      create(:chat_message, user: user)

      expect { user.destroy }.to change(ChatMessage, :count).by(-1)
    end

    it 'deletes associated api_tokens when destroyed' do
      user = create(:user)
      create(:api_token, user: user)

      expect { user.destroy }.to change(ApiToken, :count).by(-1)
    end

    it 'destroys associated user files when destroyed' do
      user = create(:user)
      create(:user_file, user: user)

      expect { user.destroy }.to change(UserFile, :count).by(-1)
    end
  end

  describe 'callbacks' do
    let(:user) { build(:user) }

    it 'broadcasts to admin_new_users after create' do
      expect { user.save! }.to have_broadcasted_to('admin_new_users')
        .with(a_string_including('<turbo-stream action=\"prepend\" target=\"admin_new_users\">'))
        .with(a_string_including(user.email))
    end
  end

  describe 'factories' do
    it 'has a valid factory' do
      user = create(:user)

      expect(user).to be_persisted
    end
  end
end

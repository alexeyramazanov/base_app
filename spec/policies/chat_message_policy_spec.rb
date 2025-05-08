# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatMessagePolicy do
  subject(:policy) { described_class }

  let(:user) { create(:user) }

  let(:own_message) { create(:chat_message, user:) }
  let(:other_user_message) { create(:chat_message) }

  permissions '.scope' do
    let!(:messages) { create_list(:chat_message, 3) }

    let(:scope) { described_class::Scope.new(user, ChatMessage.all).resolve }

    it 'scopes to all messages' do
      expect(scope).to eq(messages)
    end
  end

  permissions :index? do
    it 'grants access' do
      expect(policy).to permit(user, nil)
    end
  end

  permissions :show?, :new?, :create? do
    it 'grants access to own chat message' do
      expect(policy).to permit(user, own_message)
    end

    it 'grants access to other user chat message' do
      expect(policy).to permit(user, other_user_message)
    end
  end

  permissions :edit?, :update?, :destroy? do
    it 'denies access to own chat message' do
      expect(policy).not_to permit(user, own_message)
    end

    it 'denies access to other user chat message' do
      expect(policy).not_to permit(user, other_user_message)
    end
  end
end

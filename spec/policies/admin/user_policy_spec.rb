# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserPolicy do
  subject(:policy) { described_class }

  let(:admin_user) { create(:admin_user) }

  permissions '.scope' do
    let!(:users) { create_list(:user, 3) }

    let(:scope) { described_class::Scope.new(admin_user, User.all).resolve }

    it 'scopes to all messages' do
      expect(scope).to eq(users)
    end
  end

  permissions :index?, :request_user_stats? do
    it 'grants access to index' do
      expect(policy).to permit(admin_user, nil)
    end
  end

  permissions :show? do
    let(:user) { create(:user) }

    it 'grants access to user record' do
      expect(policy).to permit(admin_user, user)
    end
  end

  permissions :new?, :create?, :edit?, :update?, :destroy? do
    let(:user) { create(:user) }

    it 'denies access to user' do
      expect(policy).not_to permit(admin_user, user)
    end
  end
end

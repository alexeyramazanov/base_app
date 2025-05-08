# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSessionPolicy do
  subject(:policy) { described_class }

  let(:user) { create(:user) }

  let(:user_session) { create(:user_session, user:) }
  let(:other_user_session) { create(:user_session) }

  permissions '.scope' do
    let(:scope) { described_class::Scope.new(user, UserSession.all).resolve }

    before do
      user_session
      other_user_session
    end

    it 'has no scope' do
      expect { scope }.to raise_exception(Pundit::NotAuthorizedError)
    end
  end

  permissions :destroy? do
    it 'grants access to own record' do
      expect(policy).to permit(user, user_session)
    end

    it 'denies access to other user record' do # rubocop:disable RSpec/RepeatedDescription, RSpec/RepeatedExample
      expect(policy).not_to permit(user, other_user_session)
    end
  end

  permissions :index? do
    it 'denies access' do
      expect(policy).not_to permit(user, nil)
    end
  end

  permissions :show?, :new?, :create?, :edit?, :update? do
    it 'denies access to own record' do
      expect(policy).not_to permit(user, user_session)
    end

    it 'denies access to other user record' do # rubocop:disable RSpec/RepeatedDescription, RSpec/RepeatedExample
      expect(policy).not_to permit(user, other_user_session)
    end
  end
end

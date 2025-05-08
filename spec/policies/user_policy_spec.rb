# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject(:policy) { described_class }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  permissions '.scope' do
    let(:scope) { described_class::Scope.new(user, User.all).resolve }

    before do
      user
      other_user
    end

    it 'has no scope' do
      expect { scope }.to raise_exception(Pundit::NotAuthorizedError)
    end
  end

  permissions :index? do
    it 'denies access' do
      expect(policy).not_to permit(user, nil)
    end
  end

  permissions :show?, :edit?, :update? do
    it 'grants access to own record' do
      expect(policy).to permit(user, user)
    end

    it 'denies access to other users' do # rubocop:disable RSpec/RepeatedDescription, RSpec/RepeatedExample
      expect(policy).not_to permit(user, other_user)
    end
  end

  permissions :new?, :create?, :destroy? do
    it 'denies access to own record' do
      expect(policy).not_to permit(user, user)
    end

    it 'denies access to other users' do # rubocop:disable RSpec/RepeatedDescription, RSpec/RepeatedExample
      expect(policy).not_to permit(user, other_user)
    end
  end
end

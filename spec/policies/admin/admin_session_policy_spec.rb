# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AdminSessionPolicy do
  subject(:policy) { described_class }

  let(:admin_user) { create(:admin_user) }

  let(:admin_session) { create(:admin_session, admin_user:) }
  let(:other_admin_session) { create(:admin_session) }

  permissions '.scope' do
    let(:scope) { described_class::Scope.new(admin_user, AdminSession.all).resolve }

    before do
      admin_session
      other_admin_session
    end

    it 'has no scope' do
      expect { scope }.to raise_exception(Pundit::NotAuthorizedError)
    end
  end

  permissions :destroy? do
    it 'grants access to own record' do
      expect(policy).to permit(admin_user, admin_session)
    end

    it 'denies access to other admin record' do # rubocop:disable RSpec/RepeatedDescription, RSpec/RepeatedExample
      expect(policy).not_to permit(admin_user, other_admin_session)
    end
  end

  permissions :index? do
    it 'denies access' do
      expect(policy).not_to permit(admin_user, nil)
    end
  end

  permissions :show?, :new?, :create?, :edit?, :update? do
    it 'denies access to own record' do
      expect(policy).not_to permit(admin_user, admin_session)
    end

    it 'denies access to other admin record' do # rubocop:disable RSpec/RepeatedDescription, RSpec/RepeatedExample
      expect(policy).not_to permit(admin_user, other_admin_session)
    end
  end
end

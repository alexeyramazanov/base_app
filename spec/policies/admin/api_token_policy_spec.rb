# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ApiTokenPolicy do
  subject(:policy) { described_class }

  let(:admin_user) { create(:admin_user) }

  let(:api_token) { create(:api_token) }

  permissions '.scope' do
    let!(:api_tokens) { create_list(:api_token, 3) }

    let(:scope) { described_class::Scope.new(admin_user, ApiToken.all).resolve }

    it 'scopes to all api tokens' do
      expect(scope).to eq(api_tokens)
    end
  end

  permissions :index? do
    it 'grants access to index' do
      expect(policy).to permit(admin_user, nil)
    end
  end

  permissions :show?, :create?, :destroy? do
    it 'allows access to api token' do
      expect(policy).to permit(admin_user, api_token)
    end
  end

  permissions :new?, :edit?, :update? do
    it 'denies access to api token' do
      expect(policy).not_to permit(admin_user, api_token)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicGraphqlApi::VersionPolicy do
  subject(:policy) { described_class }

  let(:user) { nil }

  permissions '.scope' do
    let(:scope) { described_class::Scope.new(user, nil).resolve }

    it 'has no scope' do
      expect { scope }.to raise_exception(NoMethodError)
    end
  end

  permissions :show? do
    it 'grants access' do
      expect(policy).to permit(user, nil)
    end
  end

  permissions :index?, :new?, :create?, :edit?, :update?, :destroy? do
    it 'denies access' do
      expect(policy).not_to permit(user, nil)
    end
  end
end

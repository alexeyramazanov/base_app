# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BasePolicy do
  subject(:policy) { described_class }

  let(:admin_user) { create(:admin_user) }

  permissions '.scope' do
    let(:scope) { described_class::Scope.new(admin_user, nil).resolve }

    it 'has no scope' do
      expect { scope }.to raise_exception(NoMethodError)
    end
  end

  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it 'denies access' do
      expect(policy).not_to permit(admin_user, nil)
    end
  end
end

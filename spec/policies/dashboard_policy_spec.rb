# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardPolicy do
  subject(:policy) { described_class }

  let(:user) { create(:user) }

  permissions :show? do
    it 'grants access to dashboard' do
      expect(policy).to permit(user, nil)
    end
  end
end

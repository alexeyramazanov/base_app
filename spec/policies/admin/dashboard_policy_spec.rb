# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardPolicy do
  subject(:policy) { described_class }

  let(:admin_user) { create(:admin_user) }

  permissions :show? do
    it 'grants access to dashboard' do
      expect(policy).to permit(admin_user, nil)
    end
  end
end

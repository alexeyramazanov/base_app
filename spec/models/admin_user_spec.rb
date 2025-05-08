# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser do
  describe 'concerns' do
    it 'includes AdminAuthentication concern' do
      expect(described_class.ancestors).to include(AdminAuthentication)
    end
  end

  describe 'factories' do
    it 'has a valid factory' do
      admin_user = create(:admin_user)

      expect(admin_user).to be_persisted
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminSession do
  describe 'factories' do
    it 'has a valid factory' do
      admin_session = create(:admin_session)

      expect(admin_session).to be_persisted
    end
  end
end

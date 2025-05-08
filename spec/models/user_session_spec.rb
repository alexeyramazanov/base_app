# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSession do
  describe 'factories' do
    it 'has a valid factory' do
      user_session = create(:user_session)

      expect(user_session).to be_persisted
    end
  end
end

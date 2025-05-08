# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Current do
  let(:user_session) { create(:user_session) }
  let(:admin_session) { create(:admin_session) }

  describe 'inheritance' do
    it 'inherits from ActiveSupport::CurrentAttributes' do
      expect(described_class.superclass).to eq(ActiveSupport::CurrentAttributes)
    end
  end

  it 'stores session' do
    described_class.session = user_session

    expect(described_class.session).to eq(user_session)
  end

  it 'provides access to the user and admin_user' do
    described_class.session = user_session
    expect(described_class.user).to eq(user_session.user)

    described_class.session = admin_session
    expect(described_class.admin_user).to eq(admin_session.admin_user)
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection do
  # Since we're using AnyCable with JWT authentication, we can't test `connect` as it is part of AnyCable server

  describe 'identifiers' do
    it 'identifies by current_user' do
      user = create(:user)

      expect(described_class.identifiers).to include(:current_user)

      connect

      expect(connection.current_user).to be_nil
      connection.instance_variable_set(:@current_user, user)
      expect(connection.current_user).to eq(user)
    end

    it 'identifies by current_admin' do
      user = create(:admin_user)

      expect(described_class.identifiers).to include(:current_admin)

      connect

      expect(connection.current_admin).to be_nil
      connection.instance_variable_set(:@current_admin, user)
      expect(connection.current_admin).to eq(user)
    end
  end
end

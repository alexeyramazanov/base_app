# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe DashboardController do
  let(:user_session) { create(:user_session) }

  before do
    cookies.signed[:session_id] = user_session.id
  end

  describe 'GET #show' do
    it 'responds with success' do
      get :show

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :show }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :show }
    end
  end
end

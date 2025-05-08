# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe PagesController do
  let(:user_session) { create(:user_session) }

  describe 'GET #too_many_requests' do
    it 'responds with success' do
      get :too_many_requests

      expect(response).to be_successful
    end

    context 'when user is authenticated' do
      before do
        cookies.signed[:session_id] = user_session.id
      end

      it 'allows access to the page' do
        get :too_many_requests

        expect(response).to be_successful
      end
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :too_many_requests }
    end
  end
end

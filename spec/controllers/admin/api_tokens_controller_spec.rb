# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe Admin::ApiTokensController do
  let(:admin_user) { create(:admin_user) }
  let(:admin_session) { create(:admin_session, admin_user:) }

  before do
    cookies.signed[:admin_session_id] = admin_session.id
  end

  describe 'GET #index' do
    it 'responds with success' do
      get :index

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :index }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :index }
      let(:redirect_url) { admin_sign_in_url }
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:valid_params) { { api_token: { user_id: user.id } } }

    it 'creates a new api token' do
      expect { post :create, params: valid_params, format: :turbo_stream }.to change(ApiToken, :count).by(1)

      api_token = ApiToken.last
      expect(api_token.user).to eq(user)
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { api_token: { user_id: nil } } }

      it 'raises an error when required parameters are missing' do
        expect { post :create, params: invalid_params, format: :turbo_stream }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { post :create, params: valid_params, format: :turbo_stream }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { post :create, params: valid_params, format: :turbo_stream }
      let(:redirect_url) { admin_sign_in_url }
    end
  end
end

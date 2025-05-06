# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'
require 'shared/controller_rate_limiting'

RSpec.describe Admin::SignInController do
  describe 'GET #new' do
    it 'responds with success' do
      get :new

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :new }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :new }
    end
  end

  describe 'POST #create' do
    let(:password) { '123123' }
    let!(:admin_user) do
      create(:admin_user, email: 'admin_user@example.com', password: password, password_confirmation: password)
    end

    let(:valid_params) do
      {
        email:    admin_user.email,
        password: password
      }
    end
    let(:invalid_params) do
      {
        email:    'some_email',
        password: 'pass'
      }
    end

    context 'with valid credentials for an admin user' do
      it 'authenticates the admin' do
        expect { post :create, params: valid_params }.to change(admin_user.sessions, :count).by(1)

        admin_session = admin_user.sessions.last

        expect(cookies.signed[:admin_session_id]).to eq(admin_session.id)
      end

      it 'redirects' do
        post :create, params: valid_params

        expect(response).to be_redirect
      end
    end

    context 'with invalid credentials' do
      it 'does not authenticate the admin' do
        expect { post :create, params: invalid_params }.not_to change(AdminSession, :count)

        expect(cookies.signed[:admin_session_id]).to be_nil
      end

      it 'renders template with unprocessable entity status and flash message' do
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:alert]).to eq('Invalid email or password.')
      end
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { post :create, params: valid_params }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { post :create, params: valid_params }
    end

    it_behaves_like 'page is rate limited' do
      let(:action) { -> { post :create, params: invalid_params } }
      let(:max_requests) { 10 }
    end
  end

  describe 'DELETE #destroy' do
    let(:admin_session) { create(:admin_session) }

    before do
      cookies.signed[:admin_session_id] = admin_session.id
    end

    it 'terminates the session' do
      delete :destroy

      expect(cookies.signed[:admin_session_id]).to be_nil

      expect { admin_session.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'redirects to root url' do
      delete :destroy

      expect(response).to redirect_to(root_url)
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { delete :destroy }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { delete :destroy }
      let(:redirect_url) { admin_sign_in_url }
    end
  end
end

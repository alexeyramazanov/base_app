# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'
require 'shared/controller_rate_limiting'

RSpec.describe SignInController do
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
    let!(:user) { create(:user, email: 'user@example.com', password: password, password_confirmation: password) }

    let(:valid_params) do
      {
        email:    user.email,
        password: password
      }
    end
    let(:invalid_params) do
      {
        email:    'some_email',
        password: 'pass'
      }
    end

    context 'with valid credentials for an active user' do
      it 'authenticates the user' do
        expect { post :create, params: valid_params }.to change(user.sessions, :count).by(1)

        session = user.sessions.last

        expect(cookies.signed[:session_id]).to eq(session.id)
      end

      it 'redirects' do
        post :create, params: valid_params

        expect(response).to be_redirect
      end
    end

    context 'with invalid credentials' do
      it 'does not authenticate the user' do
        expect { post :create, params: invalid_params }.not_to change(UserSession, :count)

        expect(cookies.signed[:session_id]).to be_nil
      end

      it 'renders template with unprocessable entity status and flash message' do
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:alert]).to eq('Invalid email or password.')
      end
    end

    context 'with inactive user' do
      before do
        user.update!(activation_state: 'pending', activation_token: 'abc123',
                     activation_token_expires_at: Time.current + 1.day)
      end

      it 'does not authenticate the user' do
        expect { post :create, params: valid_params }.not_to change(user.sessions, :count)

        expect(cookies.signed[:session_id]).to be_nil
      end

      it 'renders template with unprocessable entity status and flash message' do
        post :create, params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash.now[:alert]).to include('You need to activate your account')
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
    let(:user_session) { create(:user_session) }

    before do
      cookies.signed[:session_id] = user_session.id
    end

    it 'terminates the session' do
      delete :destroy

      expect(cookies.signed[:session_id]).to be_nil

      expect { user_session.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'redirects to root url' do
      delete :destroy

      expect(response).to redirect_to(root_url)
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { delete :destroy }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { delete :destroy }
    end
  end
end

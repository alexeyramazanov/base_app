# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'
require 'shared/controller_rate_limiting'

RSpec.describe SignupController do
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
    let(:valid_params) do
      {
        user: {
          email:                 'new_user@example.com',
          password:              '123123',
          password_confirmation: '123123'
        }
      }
    end
    let(:invalid_params) do
      {
        user: {
          email:                 'invalid_email',
          password:              '123',
          password_confirmation: 'pass'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect { post :create, params: valid_params }.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq(valid_params[:user][:email])
        expect(user.authenticate_password(valid_params[:user][:password])).to eq(user)
      end

      it 'sends activation link' do
        user = instance_double(User, save: true, send_activation_link: true)
        allow(User).to receive(:new).and_return(user)

        post :create, params: valid_params

        expect(user).to have_received(:send_activation_link)
      end

      it 'redirects to success page' do
        post :create, params: valid_params

        expect(response).to redirect_to(success_signup_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        expect { post :create, params: invalid_params }.not_to change(User, :count)
      end

      it 'renders template with unprocessable entity status' do
        post :create, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
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

  describe 'GET #success' do
    it 'responds with success' do
      get :success

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :success }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :success }
    end
  end

  describe 'GET #activate' do
    let(:token) { 'abc123' }
    let!(:user) do
      create(:user, activation_state: 'pending', activation_token: token,
             activation_token_expires_at: Time.current + 1.day)
    end

    context 'with valid token' do
      it 'activates the user account' do
        get :activate, params: { token: token }

        user.reload
        expect(user.activation_state).to eq('active')
      end

      it 'redirects to sign in page with notice' do
        get :activate, params: { token: token }

        expect(response).to redirect_to(sign_in_url)
        expect(flash[:notice]).to eq('Account activated. You can sign in now.')
      end
    end

    context 'with invalid token' do
      it 'does not activate any account' do
        get :activate, params: { token: 'invalid_token' }

        expect(response).not_to redirect_to(sign_in_url)
        expect(flash[:notice]).to be_nil
      end
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :success }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :success }
    end
  end

  describe 'GET #request_activation_link' do
    it 'responds with success' do
      get :request_activation_link

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :request_activation_link }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :request_activation_link }
    end
  end

  describe 'POST #request_activation_link' do
    let!(:user) do
      create(:user, activation_state: 'pending', activation_token: 'abc123',
             activation_token_expires_at: Time.current + 1.day)
    end

    context 'when user exists' do
      before do
        allow(User).to receive(:find_by).with(email: user.email).and_return(user)
        allow(user).to receive(:send_activation_link)
      end

      it 'sends activation link' do
        post :request_activation_link, params: { email: user.email }

        expect(user).to have_received(:send_activation_link)
      end

      it 'redirects to success page' do
        post :request_activation_link, params: { email: user.email }

        expect(response).to redirect_to(success_signup_url)
      end
    end

    context 'when user does not exist' do
      let(:email) { 'nonexistent@example.com' }

      it 'does not raise an error' do
        expect { post :request_activation_link, params: { email: email } }.not_to raise_error
      end

      it 'redirects to success page' do
        post :request_activation_link, params: { email: email }

        expect(response).to redirect_to(success_signup_url)
      end
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { post :request_activation_link, params: { email: user.email } }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { post :request_activation_link, params: { email: user.email } }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'
require 'shared/controller_rate_limiting'

RSpec.describe PasswordResetController do
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
    let!(:user) { create(:user, email: 'user@example.com') }

    context 'when user exists' do
      before do
        allow(User).to receive(:find_by).with(email: user.email).and_return(user)
        allow(user).to receive(:send_password_reset_link)
      end

      it 'sends password reset link to the user' do
        post :create, params: { email: user.email }

        expect(user).to have_received(:send_password_reset_link)
      end

      it 'redirects to success page' do
        post :create, params: { email: user.email }

        expect(response).to redirect_to(success_password_reset_url)
      end
    end

    context 'when user does not exist' do
      let(:email) { 'nonexistent@example.com' }

      it 'does not raise an error' do
        expect { post :create, params: { email: email } }.not_to raise_error
      end

      it 'redirects to success page' do
        post :create, params: { email: email }

        expect(response).to redirect_to(success_password_reset_url)
      end
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { post :create, params: { email: 'user@example.com' } }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { post :create, params: { email: 'user@example.com' } }
    end

    it_behaves_like 'page is rate limited' do
      let(:action) { -> { post :create, params: { email: 'some_email' } } }
      let(:max_requests) { 5 }
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

  describe 'GET #edit' do
    let(:token) { 'abc123' }

    before do
      create(:user, reset_password_token: token, reset_password_token_expires_at: Time.current + 1.day)
    end

    context 'with valid token' do
      it 'responds with success' do
        get :edit, params: { token: token }

        expect(response).to be_successful
      end
    end

    context 'with invalid token' do
      it 'redirects to password reset page with alert' do
        get :edit, params: { token: 'invalid_token' }

        expect(response).to redirect_to(password_reset_url)
        expect(flash[:alert]).to eq('Password reset link is invalid or has expired.')
      end
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :edit, params: { token: token } }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :edit, params: { token: token } }
    end
  end

  describe 'PATCH #update' do
    let(:token) { 'abc123' }
    let!(:user) { create(:user, reset_password_token: token, reset_password_token_expires_at: Time.current + 1.day) }
    let(:new_password) { 'new_password' }

    let(:valid_params) do
      {
        token: token,
        user:  {
          password:              new_password,
          password_confirmation: new_password
        }
      }
    end
    let(:invalid_user_params) do
      {
        token: token,
        user:  {
          password:              'new',
          password_confirmation: 'different'
        }
      }
    end
    let(:invalid_token) do
      {
        token: 'invalid',
        user:  {
          password:              new_password,
          password_confirmation: new_password
        }
      }
    end

    context 'with valid token' do
      context 'with valid password parameters' do
        it 'updates the user password' do
          patch :update, params: valid_params

          user.reload
          expect(user.authenticate_password(new_password)).to eq(user)
        end

        it 'redirects to sign in page with notice' do
          patch :update, params: valid_params

          expect(response).to redirect_to(sign_in_url)
          expect(flash[:notice]).to eq('Password has been reset.')
        end
      end

      context 'with invalid password parameters' do
        it 'does not update the user password' do
          patch :update, params: invalid_user_params

          user.reload
          expect(user.authenticate_password(new_password)).to be(false)
        end

        it 'responds with unprocessable entity status' do
          patch :update, params: invalid_user_params

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'with invalid token' do
      it 'redirects to password reset page with alert' do
        patch :update, params: invalid_token

        expect(response).to redirect_to(password_reset_url)
        expect(flash[:alert]).to eq('Password reset link is invalid or has expired.')
      end
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { patch :update, params: valid_params }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { patch :update, params: valid_params }
    end
  end
end

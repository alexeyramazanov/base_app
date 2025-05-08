# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe ProfileController do
  let(:password) { '123123' }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:user_session) { create(:user_session, user: user) }

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

  describe 'PATCH #update' do
    context 'with correct current password' do
      let(:new_password) { 'new_password' }
      let(:params) do
        {
          current_password:      password,
          password:              new_password,
          password_confirmation: new_password
        }
      end

      it 'updates the password' do
        patch :update, params: params

        user.reload
        expect(user.authenticate_password(password)).to be(false)
        expect(user.authenticate_password(new_password)).to eq(user)
      end

      it 'redirects user with flash message' do
        patch :update, params: params

        expect(response).to redirect_to(profile_url)
        expect(flash[:notice]).to eq('Password successfully updated')
      end
    end

    context 'with incorrect current password' do
      let(:new_password) { 'new_password' }
      let(:params) do
        {
          current_password:      'wrong_password',
          password:              new_password,
          password_confirmation: new_password
        }
      end

      it 'does not update the password' do
        patch :update, params: params

        user.reload
        expect(user.authenticate_password(password)).to eq(user)
        expect(user.authenticate_password(new_password)).to be(false)
      end

      it 'renders page with flash message' do
        patch :update, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq('Incorrect current password')
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          current_password:      '123123',
          password:              'new_password',
          password_confirmation: 'different_password'
        }
      end

      it 'does not update the password' do
        patch :update, params: params

        user.reload
        expect(user.authenticate_password(password)).to eq(user)
        expect(user.authenticate_password(params[:password])).to be(false)
        expect(user.authenticate_password(params[:password_confirmation])).to be(false)
      end

      it 'shows error message' do
        patch :update, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq("Password confirmation doesn't match Password")
      end
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { patch :update, params: { current_password: '123123' } }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { patch :update, params: { current_password: '123123' } }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiTokenAuthentication do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user:) }

  controller(ActionController::Base) do
    include ApiTokenAuthentication # rubocop:disable RSpec/DescribedClass

    def index
      if current_user
        render plain: "Hello, #{current_user.email}!"
      else
        render plain: 'Unauthorized', status: :unauthorized
      end
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
    end
  end

  describe 'CSRF protection' do
    before do
      allow(controller).to receive(:verify_authenticity_token)
    end

    it 'is disabled' do
      get :index

      expect(controller).to have_received(:verify_authenticity_token).exactly(0).times
    end
  end

  describe 'authentication flow' do
    context 'with valid token' do
      before do
        request.headers['Authorization'] = "Bearer #{api_token.token}"
      end

      it 'allows access to the page' do
        get :index

        expect(response).to be_successful
        expect(response.body).to eq("Hello, #{user.email}!")
      end

      it 'updates the last used at timestamp' do
        expect(api_token.last_used_at).to be_nil

        get :index

        api_token.reload
        expect(api_token.last_used_at).to be_within(2.seconds).of(Time.current)
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = 'Bearer invalid_token'
      end

      it 'returns unauthorized status' do
        get :index

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with malformed authorization header' do
      before do
        request.headers['Authorization'] = 'InvalidFormat'
      end

      it 'returns unauthorized status' do
        get :index

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'without authorization header' do
      before do
        request.headers['Authorization'] = nil
      end

      it 'returns unauthorized status' do
        get :index

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

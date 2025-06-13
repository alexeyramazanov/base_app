# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::Root do
  let(:api_token) { create(:api_token) }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    test_endpoints = Class.new(Grape::API) do
      namespace :test do
        get :auth do
          authorize :dashboard, :show?

          { success: true }
        end

        get :auth_scope do
          policy_scope(Document)

          { success: true }
        end

        get :forbidden do
          # fails, because `authorize` or `policy_scope` are missing
          { success: true }
        end

        get :public_route do
          { success: true }
        end
      end
    end

    described_class.class_eval { mount test_endpoints }
  end

  describe 'swagger documentation' do
    it 'is present' do
      get '/public_api/swagger_doc.json'

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data['basePath']).to eq('/public_api')
    end
  end

  describe 'global callbacks' do
    describe 'authentication' do
      context 'when Authorization header is valid' do
        it 'returns 200 status code with appropriate response' do
          make_api_request :get, '/public_api/test/auth', api_token.token

          expect(response).to have_http_status(:ok)

          data = JSON.parse(response.body)
          expect(data).to eq({ 'success' => true })
        end

        it 'updates token last_used_at timestamp' do
          expect(api_token.last_used_at).to be_nil

          make_api_request :get, '/public_api/test/auth', api_token.token

          api_token.reload
          expect(api_token.last_used_at).to be_within(2.seconds).of(Time.current)
        end
      end

      context 'when Authorization header is missing' do
        it 'returns 401 status code with appropriate response' do
          make_api_request :get, '/public_api/test/auth'

          expect(response).to have_http_status(:unauthorized)

          data = JSON.parse(response.body)
          expect(data).to eq({ 'code' => 401, 'message' => 'Unauthorized', 'errors' => [] })
        end
      end

      context 'when Authorization header is invalid' do
        it 'returns 401 status code with appropriate response' do
          make_api_request :get, '/public_api/test/auth', 'invalid_token'

          expect(response).to have_http_status(:unauthorized)

          data = JSON.parse(response.body)
          expect(data).to eq({ 'code' => 401, 'message' => 'Unauthorized', 'errors' => [] })
        end
      end

      context 'when route is public' do
        before do
          stub_const('PublicRestApi::Root::PUBLIC_ROUTES', %w[/public_api/test/public_route])
        end

        it 'does not require authentication' do
          make_api_request :get, '/public_api/test/public_route'

          expect(response).to have_http_status(:ok)

          data = JSON.parse(response.body)
          expect(data).to eq({ 'success' => true })
        end
      end
    end

    describe 'authorization' do
      context 'when resource is individually authorized' do
        it 'returns 200 status code with appropriate response' do
          make_api_request :get, '/public_api/test/auth', api_token.token

          expect(response).to have_http_status(:ok)

          data = JSON.parse(response.body)
          expect(data).to eq({ 'success' => true })
        end
      end

      context 'when resource is scope authorized' do
        it 'returns 200 status code with appropriate response' do
          make_api_request :get, '/public_api/test/auth_scope', api_token.token

          expect(response).to have_http_status(:ok)

          data = JSON.parse(response.body)
          expect(data).to eq({ 'success' => true })
        end
      end

      context 'when resource is not authorized' do
        it 'returns 403 status code with appropriate response' do
          make_api_request :get, '/public_api/test/forbidden', api_token.token

          expect(response).to have_http_status(:forbidden)

          data = JSON.parse(response.body)
          expect(data).to eq({ 'code' => 403, 'message' => 'Forbidden', 'errors' => [] })
        end
      end

      context 'when route is public' do
        before do
          stub_const('PublicRestApi::Root::PUBLIC_ROUTES', %w[/public_api/test/public_route])
        end

        it 'does not require authentication' do
          make_api_request :get, '/public_api/test/public_route'

          expect(response).to have_http_status(:ok)

          data = JSON.parse(response.body)
          expect(data).to eq({ 'success' => true })
        end
      end
    end
  end
end

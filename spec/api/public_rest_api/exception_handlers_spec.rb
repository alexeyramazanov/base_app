# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicRestApi::ExceptionHandlers do
  let(:api_token) { create(:api_token) }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    test_endpoints = Class.new(Grape::API) do
      namespace :test do
        get :validation_error do
          errors = [Grape::Exceptions::Validation.new(params: ['name'], message: 'is missing')]
          raise Grape::Exceptions::ValidationErrors.new(errors:)
        end

        get :record_not_found do
          raise ActiveRecord::RecordNotFound
        end

        get :pagination_error do
          Pagy.new # without params will trigger an exception
        end

        get :error do
          raise StandardError, 'error'
        end
      end
    end

    PublicRestApi::Root.class_eval { mount test_endpoints }
  end

  describe 'validation errors' do
    it 'returns 422 status code with appropriate response' do
      make_api_request :get, '/public_api/test/validation_error', api_token.token

      expect(response).to have_http_status(:unprocessable_content)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 422, 'message' => 'Unprocessable Content', 'errors' => ['name is missing'] })
    end
  end

  describe 'ActiveRecord::RecordNotFound' do
    it 'returns 404 status code with appropriate response' do
      make_api_request :get, '/public_api/test/record_not_found', api_token.token

      expect(response).to have_http_status(:not_found)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 404, 'message' => 'Not Found', 'errors' => [] })
    end
  end

  describe 'pagination error' do
    it 'returns 422 status code with appropriate response' do
      make_api_request :get, '/public_api/test/pagination_error', api_token.token

      expect(response).to have_http_status(:unprocessable_content)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 422, 'message' => 'Unprocessable Content',
                           'errors' => ['expected :count >= 0; got nil'] })
    end
  end

  describe 'generic error' do
    it 'returns 500 status code with appropriate response' do
      make_api_request :get, '/public_api/test/error', api_token.token

      expect(response).to have_http_status(:internal_server_error)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 500, 'message' => 'Internal Server Error', 'errors' => [] })
    end
  end
end

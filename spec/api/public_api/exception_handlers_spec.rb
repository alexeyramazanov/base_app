# frozen_string_literal: true

require 'rails_helper'

class PublicApiTestExceptionHandlersEndpoints < Grape::API
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

module PublicApi
  class Root
    mount PublicApiTestExceptionHandlersEndpoints
  end
end

RSpec.describe PublicApi::ExceptionHandlers do
  let(:api_token) { create(:api_token) }

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

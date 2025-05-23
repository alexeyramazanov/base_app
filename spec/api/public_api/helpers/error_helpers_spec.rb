# frozen_string_literal: true

require 'rails_helper'

class PublicApiTestErrorHelpersEndpoints < Grape::API
  namespace :test do
    params do
      requires :code, type: Integer
    end
    get :common_errors do
      case params[:code]
      when 401 then error_unauthorized!
      when 403 then error_forbidden!
      when 404 then error_not_found!
      when 422 then error_unprocessable_entity!('error')
      when 500 then internal_server_error!
      else internal_server_error!
      end
    end
  end
end

module PublicApi
  class Root
    mount PublicApiTestErrorHelpersEndpoints
  end
end

RSpec.describe PublicApi::Helpers::ErrorHelpers do
  let(:api_token) { create(:api_token) }

  describe 'error_unauthorized!' do
    it 'returns 401 status code with appropriate response' do
      make_api_request :get, '/public_api/test/common_errors', api_token.token, params: { code: 401 }

      expect(response).to have_http_status(:unauthorized)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 401, 'message' => 'Unauthorized', 'errors' => [] })
    end
  end

  describe 'error_forbidden!' do
    it 'returns 403 status code with appropriate response' do
      make_api_request :get, '/public_api/test/common_errors', api_token.token, params: { code: 403 }

      expect(response).to have_http_status(:forbidden)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 403, 'message' => 'Forbidden', 'errors' => [] })
    end
  end

  describe 'error_not_found!' do
    it 'returns 404 status code with appropriate response' do
      make_api_request :get, '/public_api/test/common_errors', api_token.token, params: { code: 404 }

      expect(response).to have_http_status(:not_found)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 404, 'message' => 'Not Found', 'errors' => [] })
    end
  end

  describe 'error_unprocessable_entity!' do
    it 'returns 422 status code with appropriate response' do
      make_api_request :get, '/public_api/test/common_errors', api_token.token, params: { code: 422 }

      expect(response).to have_http_status(:unprocessable_content)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 422, 'message' => 'Unprocessable Content', 'errors' => ['error'] })
    end
  end

  describe 'internal_server_error!' do
    it 'returns 500 status code with appropriate response' do
      make_api_request :get, '/public_api/test/common_errors', api_token.token, params: { code: 500 }

      expect(response).to have_http_status(:internal_server_error)

      data = JSON.parse(response.body)
      expect(data).to eq({ 'code' => 500, 'message' => 'Internal Server Error', 'errors' => [] })
    end
  end

  describe '.failures' do
    it 'returns a grape failure definitions for specified codes' do
      failures = described_class.failures(401, 500)

      expect(failures.count).to eq(2)

      failure401 = failures.find { |f| f[:code] == 401 }
      expect(failure401[:message]).to eq('Unauthorized')

      failure500 = failures.find { |f| f[:code] == 500 }
      expect(failure500[:message]).to eq('Internal Server Error')
    end

    context 'when error code is 422' do
      it 'returns special value for errors' do
        failures = described_class.failures(422)
        failure = failures.first

        expect(failure[:message]).to eq('Unprocessable Content')
        expect(failure[:examples][:'application/json'][:errors]).to contain_exactly("Invalid value for field 'name'")
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'shared/public_api'

RSpec.describe PublicRestApi::V1::Documents do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user:) }

  let!(:document1) { create(:document, user:) }
  let!(:document2) { create(:document, user:) }

  before do
    create_list(:document, 3)
  end

  describe 'GET /public_api/v1/documents' do
    let(:path) { '/public_api/v1/documents' }

    it_behaves_like 'authenticated_endpoint' do
      let(:path) { super() }
    end

    it 'returns list of documents for current user' do
      make_api_request :get, path, api_token.token

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data.count).to eq(2)
      expect(data.map { |record| record['id'] }).to contain_exactly(document1.id, document2.id)
    end
  end

  describe 'GET /public_api/v1/documents/{id}/download' do
    let(:path) { "/public_api/v1/documents/#{id}/download" }
    let(:id) { document1.id }

    it_behaves_like 'authenticated_endpoint' do
      let(:path) { super() }
    end

    it 'returns download url for the document' do
      make_api_request :get, path, api_token.token

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data['id']).to eq(document1.id)
      expect(data['url']).to be_present
      expect(data['url']).to include(document1.file.id)
    end
  end
end

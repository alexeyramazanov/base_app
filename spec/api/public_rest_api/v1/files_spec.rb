# frozen_string_literal: true

require 'rails_helper'
require 'shared/public_api'

RSpec.describe PublicRestApi::V1::Files do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user:) }

  let!(:user_file1) { create(:user_file, user:) }
  let!(:user_file2) { create(:user_file, user:) }

  before do
    create_list(:user_file, 3)
  end

  describe 'GET /public_api/v1/files' do
    let(:path) { '/public_api/v1/files' }

    it_behaves_like 'authenticated_endpoint' do
      let(:path) { super() }
    end

    it 'returns list of files for current user' do
      make_api_request :get, path, api_token.token

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data.count).to eq(2)
      expect(data.map { |record| record['id'] }).to contain_exactly(user_file1.id, user_file2.id)
    end
  end

  describe 'GET /public_api/v1/files/{id}/download' do
    let(:path) { "/public_api/v1/files/#{id}/download" }
    let(:id) { user_file1.id }

    it_behaves_like 'authenticated_endpoint' do
      let(:path) { super() }
    end

    it 'returns download url for the user file' do
      make_api_request :get, path, api_token.token

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data['id']).to eq(user_file1.id)
      expect(data['url']).to be_present
      expect(data['url']).to include(user_file1.attachment.id)
    end
  end
end

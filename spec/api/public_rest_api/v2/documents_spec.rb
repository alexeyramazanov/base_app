# frozen_string_literal: true

require 'rails_helper'
require 'shared/public_api'

RSpec.describe PublicRestApi::V2::Documents do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user:) }

  let!(:document1) { create(:document, user:) }
  let!(:document2) { create(:document, user:) }

  before do
    create_list(:document, 3)
  end

  describe 'GET /public_api/v2/documents' do
    let(:path) { '/public_api/v2/documents' }

    it_behaves_like 'authenticated_endpoint' do
      let(:path) { super() }
    end
    it_behaves_like 'paginated_endpoint' do
      let(:path) { super() }
      let(:token) { api_token.token }
    end

    it 'returns list of documents for current user' do
      make_api_request :get, path, api_token.token

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data['records'].count).to eq(2)
      expect(data['records'].map { |record| record['id'] }).to contain_exactly(document1.id, document2.id)
    end
  end

  describe 'POST /public_api/v2/documents' do
    let(:path) { '/public_api/v2/documents' }

    let(:base64_data) { File.read(Rails.root.join('spec/fixtures/logo_base64.txt')).strip }

    let(:valid_params) do
      {
        file_name: 'logo.png',
        data:      base64_data
      }
    end

    it_behaves_like 'authenticated_endpoint' do
      let(:request_method) { :post }
      let(:path) { super() }
    end

    it 'creates a document for user' do
      expect { make_api_request :post, path, api_token.token, params: valid_params }
        .to change(user.documents, :count).by(1)

      expect(response).to have_http_status(:created)

      document = user.documents.last
      expect(document.file.metadata).to eq({ 'size' => 30_487, 'filename' => 'logo.png', 'mime_type' => 'image/png' })
    end

    it 'returns new document record' do
      make_api_request :post, path, api_token.token, params: valid_params

      expect(response).to have_http_status(:created)

      data = JSON.parse(response.body)
      expect(data['user_id']).to eq(user.id)
      expect(data['file_name']).to eq(valid_params[:file_name])
      expect(data['file_size']).to eq(30_487)
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        {
          data: base64_data
        }
      end

      it 'returns 422 status code with appropriate response' do
        make_api_request :post, path, api_token.token, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)

        data = JSON.parse(response.body)
        expect(data).to eq({ 'code' => 422, 'message' => 'Unprocessable Content',
                             'errors' => ['file_name is missing'] })
      end
    end

    context 'when file is invalid' do
      let(:invalid_params) do
        {
          file_name: 'logo.png',
          data:      ''
        }
      end

      it 'returns 422 status code with appropriate response' do
        make_api_request :post, path, api_token.token, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)

        data = JSON.parse(response.body)
        expect(data).to eq({ 'code' => 422, 'message' => 'Unprocessable Content',
                             'errors' => ['Invalid file'] })
      end
    end

    context 'when document failed to be saved' do
      let(:invalid_params) do
        {
          file_name: 'logo.png',
          data:      "data:image/png;base64,#{Base64.encode64('text')}"
        }
      end

      it 'returns 422 status code with appropriate response' do
        make_api_request :post, path, api_token.token, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)

        data = JSON.parse(response.body)
        expect(data).to eq({ 'code' => 422, 'message' => 'Unprocessable Content',
                             'errors' => ['File type must be one of: image/jpeg, image/png'] })
      end
    end
  end

  describe 'GET /public_api/v2/documents/{id}/download' do
    let(:path) { "/public_api/v2/documents/#{id}/download" }
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

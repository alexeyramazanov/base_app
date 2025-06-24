# frozen_string_literal: true

require 'rails_helper'
require 'shared/public_api'

RSpec.describe PublicRestApi::V2::Files do
  let(:user) { create(:user) }
  let(:api_token) { create(:api_token, user:) }

  let!(:user_file1) { create(:user_file, user:) }
  let!(:user_file2) { create(:user_file, user:) }

  before do
    create_list(:user_file, 3)
  end

  describe 'GET /public_api/v2/files' do
    let(:path) { '/public_api/v2/files' }

    it_behaves_like 'authenticated_endpoint' do
      let(:path) { super() }
    end
    it_behaves_like 'paginated_endpoint' do
      let(:path) { super() }
      let(:token) { api_token.token }
    end

    it 'returns list of files for current user' do
      make_api_request :get, path, api_token.token

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data['records'].count).to eq(2)
      expect(data['records'].map { |record| record['id'] }).to contain_exactly(user_file1.id, user_file2.id)
    end
  end

  describe 'POST /public_api/v2/files' do
    let(:path) { '/public_api/v2/files' }

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

    it 'creates a file for user' do
      expect { make_api_request :post, path, api_token.token, params: valid_params }
        .to change(user.user_files, :count).by(1)

      expect(response).to have_http_status(:created)

      user_file = user.user_files.last
      expect(user_file.attachment.metadata)
        .to eq({ 'size' => 30_487, 'filename' => 'logo.png', 'mime_type' => 'image/png' })
    end

    it 'returns new user file record' do
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

    context 'when user file failed to be saved' do
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
        expect(data).to eq(
          {
            'code'    => 422,
            'message' => 'Unprocessable Content',
            'errors'  => ['Attachment type must be one of: image/jpg, image/jpeg, image/png, application/pdf']
          }
        )
      end
    end
  end

  describe 'GET /public_api/v2/files/{id}/download' do
    let(:path) { "/public_api/v2/files/#{id}/download" }
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

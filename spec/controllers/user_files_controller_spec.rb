# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe UserFilesController do
  let(:user) { create(:user) }
  let(:user_session) { create(:user_session, user: user) }

  before do
    cookies.signed[:session_id] = user_session.id
  end

  describe 'GET #index' do
    before do
      create_list(:user_file, 2, user: user)
    end

    it 'responds with success' do
      get :index

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :index }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :index }
    end
  end

  describe 'POST #create' do
    let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg')) }

    it 'creates a new user file' do
      expect { post :create, params: { file: file } }.to change(UserFile, :count).by(1)

      user_file = UserFile.last
      expect(user_file.user).to eq(user)
      expect(user_file.attachment.size).to eq(file.size)
    end

    it 'redirects to user files index' do
      post :create, params: { file: file }

      expect(response).to redirect_to(files_url)
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { post :create, params: { file: file } }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { post :create, params: { file: file } }
    end
  end

  describe 'DELETE #destroy' do
    let!(:user_file) { create(:user_file, user: user) }
    let!(:other_user_file) { create(:user_file) }

    it 'destroys the user file' do
      expect { delete :destroy, params: { id: user_file.id } }.to change(user.user_files, :count).by(-1)

      expect { user_file.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      expect { other_user_file.reload }.not_to raise_exception
    end

    it 'redirects to user files index' do
      delete :destroy, params: { id: user_file.id }

      expect(response).to redirect_to(files_url)
    end

    context 'when trying to delete another user file' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect { delete :destroy, params: { id: other_user_file.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { delete :destroy, params: { id: user_file.id } }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { delete :destroy, params: { id: user_file.id } }
    end
  end

  describe 'GET #s3_params' do
    let(:s3_params) { { key: 'cache/123456', url: 'https://example.com/upload' }.to_json }

    before do
      allow(UserFileUploader)
        .to receive(:presign_response)
        .and_return([200, { 'Content-Type' => 'application/json' }, s3_params])
    end

    it 'returns presigned S3 params' do
      get :s3_params

      expect(UserFileUploader).to have_received(:presign_response).with(:cache, request.env)

      expect(response.status).to eq(200)
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response.body).to eq(s3_params)
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :s3_params }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :s3_params }
    end
  end

  describe 'GET #preview' do
    let(:user_file) { create(:user_file, user: user) }
    let(:other_user_file) { create(:user_file) }

    it 'responds with successful turbo stream response' do
      get :preview, params: { id: user_file.id }, format: :turbo_stream

      expect(response).to be_successful
      expect(response.content_type).to eq('text/vnd.turbo-stream.html; charset=utf-8')
    end

    context 'when trying to preview another user file' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect { get :preview, params: { id: other_user_file.id }, format: :turbo_stream }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :preview, params: { id: user_file.id }, format: :turbo_stream }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :preview, params: { id: user_file.id }, format: :turbo_stream }
    end
  end

  describe 'GET #download' do
    let(:user_file) { create(:user_file, user: user) }
    let(:other_user_file) { create(:user_file) }

    it 'redirects to the file URL' do
      get :download, params: { id: user_file.id }

      expect(response).to redirect_to(user_file.attachment.url)
    end

    # have to have this spec because in test env we use FileSystem as a storage backend
    # which does not support a response_content_disposition option
    it 'passes the correct content disposition header' do
      expect_any_instance_of(Shrine::UploadedFile) # rubocop:disable RSpec/AnyInstance
        .to receive(:url)
        .with(response_content_disposition: "attachment; filename=\"sample.jpg\"; filename*=UTF-8''sample.jpg")
        .and_call_original

      get :download, params: { id: user_file.id }
    end

    context 'when trying to download another user file' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect { get :download, params: { id: other_user_file.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :download, params: { id: user_file.id } }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :download, params: { id: user_file.id } }
    end
  end
end

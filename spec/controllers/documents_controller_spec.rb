# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe DocumentsController do
  let(:user) { create(:user) }
  let(:user_session) { create(:user_session, user: user) }

  before do
    cookies.signed[:session_id] = user_session.id
  end

  describe 'GET #index' do
    before do
      create_list(:document, 2, user: user)
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

    it 'creates a new document' do
      expect { post :create, params: { file: file } }.to change(Document, :count).by(1)

      document = Document.last
      expect(document.user).to eq(user)
      expect(document.file.size).to eq(file.size)
    end

    it 'redirects to documents index' do
      post :create, params: { file: file }

      expect(response).to redirect_to(documents_url)
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { post :create, params: { file: file } }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { post :create, params: { file: file } }
    end
  end

  describe 'DELETE #destroy' do
    let!(:document) { create(:document, user: user) }
    let!(:other_user_document) { create(:document) }

    it 'destroys the document' do
      expect { delete :destroy, params: { id: document.id } }.to change(user.documents, :count).by(-1)

      expect { document.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      expect { other_user_document.reload }.not_to raise_exception
    end

    it 'redirects to documents index' do
      delete :destroy, params: { id: document.id }

      expect(response).to redirect_to(documents_path)
    end

    context 'when trying to delete another user document' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect { delete :destroy, params: { id: other_user_document.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { delete :destroy, params: { id: document.id } }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { delete :destroy, params: { id: document.id } }
    end
  end

  describe 'GET #s3_params' do
    let(:s3_params) { { key: 'cache/123456', url: 'https://example.com/upload' }.to_json }

    before do
      allow(DocumentUploader)
        .to receive(:presign_response)
        .and_return([200, { 'Content-Type' => 'application/json' }, s3_params])
    end

    it 'returns presigned S3 params' do
      get :s3_params

      expect(DocumentUploader).to have_received(:presign_response).with(:cache, request.env)

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

  describe 'GET #download' do
    let(:document) { create(:document, user: user) }
    let(:other_user_document) { create(:document) }

    it 'redirects to the file URL' do
      get :download, params: { id: document.id }

      expect(response).to redirect_to(document.file.url)
    end

    # have to have this spec because in test env we use FileSystem as a storage backend
    # which does not support a response_content_disposition option
    it 'passes the correct content disposition header' do
      expect_any_instance_of(Shrine::UploadedFile) # rubocop:disable Rspec/AnyInstance
        .to receive(:url)
        .with(response_content_disposition: "attachment; filename=\"sample.jpg\"; filename*=UTF-8''sample.jpg")
        .and_call_original

      get :download, params: { id: document.id }
    end

    context 'when trying to download another user document' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect { get :download, params: { id: other_user_document.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :download, params: { id: document.id } }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :download, params: { id: document.id } }
    end
  end
end

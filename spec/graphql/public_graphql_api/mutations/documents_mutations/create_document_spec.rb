# frozen_string_literal: true

require 'rails_helper'
require 'shared/graphql'

RSpec.describe PublicGraphqlApi::Mutations::DocumentsMutations::CreateDocument do
  let(:user) { create(:user) }

  let(:base64_data) { File.read(Rails.root.join('spec/fixtures/logo_base64.txt')).strip }

  let(:mutation) do
    <<~GQL
      mutation CreateDocument($input: CreateDocumentInput!) {
        createDocument(input: $input) {
          document {
            id
            fileName
            fileSize
          }
        }
      }
    GQL
  end
  let(:variables) do
    {
      input: {
        fileName: 'logo.png',
        data:     base64_data
      }
    }
  end

  it_behaves_like 'authenticated graphql endpoint' do
    let(:query) { mutation }
    let(:variables) { super() }
  end

  it 'creates a new document' do
    expect { execute_graphql(mutation, user, variables) }.to change(user.documents, :count).by(1)

    expect(success?).to be(true)

    document = user.documents.last
    expect(document.file.metadata).to eq({ 'size' => 30_487, 'filename' => 'logo.png', 'mime_type' => 'image/png' })
  end

  it 'returns created document' do
    execute_graphql(mutation, user, variables)

    expect(success?).to be(true)
    expect(data['createDocument']['document']['fileName']).to eq('logo.png')
    expect(data['createDocument']['document']['fileSize']).to eq(30_487)
  end

  context 'with invalid input params' do
    let(:variables) do
      {
        input: {
          fileName: '',
          data:     base64_data
        }
      }
    end

    it 'returns a validation error' do
      execute_graphql(mutation, user, variables)

      expect(success?).to be(false)
      expect_error_code('VALIDATION_ERROR')
      expect_validation_errors([{ field: 'file', message: 'extension must be one of: jpg, jpeg, png' }])
    end
  end

  context 'with invalid file data' do
    let(:base64_data) { 'invalid_base64' }

    it 'returns a validation error' do
      execute_graphql(mutation, user, variables)

      expect(success?).to be(false)
      expect_error_code('VALIDATION_ERROR')
      expect_validation_errors([{ field: nil, message: 'Invalid file' }])
    end
  end
end

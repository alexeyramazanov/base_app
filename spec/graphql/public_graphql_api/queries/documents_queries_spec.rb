# frozen_string_literal: true

require 'rails_helper'
require 'shared/graphql'

RSpec.describe PublicGraphqlApi::Queries::DocumentsQueries do
  let(:user) { create(:user) }

  describe 'documents query' do
    let!(:documents) { create_list(:document, 3, user:) }
    let!(:other_documents) { create_list(:document, 2) } # rubocop:disable RSpec/LetSetup

    let(:query) do
      <<~GQL
        query {
          documents {
            nodes {
              id
            }
          }
        }
      GQL
    end

    let(:paginated_query) do
      <<~GQL
        query {
          documents(first: 2) {
            nodes {
              id
            }
            pageInfo {
              hasNextPage
            }
          }
        }
      GQL
    end

    let(:edges_query) do
      <<~GQL
        query {
          documents {
            edges {
              cursor
              node {
                id
              }
            }
          }
        }
      GQL
    end

    it_behaves_like 'authenticated graphql endpoint' do
      let(:query) { super() }
    end

    it 'returns an ordered list of documents' do
      execute_graphql(query, user)

      expect(success?).to be(true)

      expected_document_ids = user.documents.order(id: :desc).map(&:to_gid_param)
      received_document_ids = data['documents']['nodes'].map { |d| d['id'] }
      expect(received_document_ids).to eq(expected_document_ids)
    end

    it 'supports pagination' do
      execute_graphql(paginated_query, user)

      expect(success?).to be(true)
      expect(data['documents']['nodes'].length).to eq(2)
      expect(data['documents']['pageInfo']['hasNextPage']).to be(true)
    end

    it 'supports edges' do
      execute_graphql(edges_query, user)

      expect(success?).to be(true)

      expected_document_ids = documents.map(&:to_gid_param)
      received_document_ids = data['documents']['edges'].map { |d| d['node']['id'] }
      expect(received_document_ids).to match_array(expected_document_ids)

      expected_cursors = %w[1 2 3]
      received_cursors = data['documents']['edges'].map { |d| Base64.decode64(d['cursor']) }
      expect(received_cursors).to match_array(expected_cursors)
    end
  end

  describe 'document query' do
    let!(:document) { create(:document, user:) }
    let!(:other_document) { create(:document) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          document(id: $id) {
            id
            userId
            url
          }
        }
      GQL
    end
    let(:variables) do
      {
        id: document.to_gid_param
      }
    end

    it_behaves_like 'authenticated graphql endpoint' do
      let(:query) { super() }
      let(:variables) { super() }
    end

    it_behaves_like 'authorized graphql endpoint' do
      let(:query) { super() }
      let(:user) { super() }
      let(:variables) { { id: other_document.to_gid_param } }
    end

    it_behaves_like 'graphql endpoint validating ID format' do
      let(:query) { super() }
      let(:user) { super() }
      let(:variables) { { id: 'invalid' } }
    end

    it 'returns a specific document' do
      execute_graphql(query, user, variables)

      expect(success?).to be(true)

      expected_data = {
        'id'     => document.to_gid_param,
        'userId' => user.id,
        'url'    => document.file.url
      }
      expect(data['document']).to eq(expected_data)
    end
  end
end

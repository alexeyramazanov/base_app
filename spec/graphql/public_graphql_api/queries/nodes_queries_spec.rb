# frozen_string_literal: true

require 'rails_helper'
require 'shared/graphql'

class PublicGraphqlApiTypeResolutionUnsupportedModel
end

module PublicGraphqlApiTypeResolutionTest
  extend ActiveSupport::Concern

  included do
    field :spec_type_resolution_test, PublicGraphqlApi::Types::NodeType, authenticate: false
  end

  def spec_type_resolution_test
    PublicGraphqlApiTypeResolutionUnsupportedModel.new
  end
end

module PublicGraphqlApi
  module Types
    class QueryType
      include PublicGraphqlApiTypeResolutionTest
    end
  end
end

RSpec.describe PublicGraphqlApi::Queries::NodesQueries do
  let(:user) { create(:user) }

  describe 'nodes query' do
    let!(:documents) { create_list(:document, 2, user:) }
    let!(:other_document) { create(:document) }

    let(:query) do
      <<~GQL
        query($ids: [ID!]!) {
          nodes(ids: $ids) {
            id
          }
        }
      GQL
    end

    let(:variables) do
      {
        ids: documents.map(&:to_gid_param)
      }
    end

    it_behaves_like 'authenticated graphql endpoint' do
      let(:query) { super() }
      let(:variables) { super() }
    end

    it_behaves_like 'authorized graphql endpoint' do
      let(:query) { super() }
      let(:user) { super() }
      let(:variables) { { ids: [documents.first.to_gid_param, other_document.to_gid_param] } }
    end

    it_behaves_like 'graphql endpoint validating ID format' do
      let(:query) { super() }
      let(:user) { super() }
      let(:variables) { { ids: [documents.first.to_gid_param, 'invalid'] } }
    end

    it 'returns the correct nodes for given IDs' do
      execute_graphql(query, user, variables)

      expect(success?).to be(true)

      received_ids = data['nodes'].map { |n| n['id'] }
      expect(received_ids).to match_array(variables[:ids])
    end

    context 'with specified types' do
      let(:query) do
        <<~GQL
          query($ids: [ID!]!) {
            nodes(ids: $ids) {
              id
              ... on Document {
                id
                userId
              }
            }
          }
        GQL
      end

      it 'returns fields for specified types' do
        execute_graphql(query, user, variables)

        expect(success?).to be(true)

        expected_documents = documents.map { |d| { 'id' => d.to_gid_param, 'userId' => d.user_id } }
        expect(data['nodes']).to match_array(expected_documents)
      end
    end
  end

  describe 'node query' do
    let!(:document) { create(:document, user:) }
    let!(:other_document) { create(:document) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          node(id: $id) {
            id
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

    it 'returns the correct node for given ID' do
      execute_graphql(query, user, variables)

      expect(success?).to be(true)
      expect(data['node']['id']).to eq(document.to_gid_param)
    end

    context 'with specified type' do
      let(:query) do
        <<~GQL
          query($id: ID!) {
            node(id: $id) {
              id
              ... on Document {
                id
                userId
              }
            }
          }
        GQL
      end

      it 'returns fields for specified types' do
        execute_graphql(query, user, variables)

        expect(success?).to be(true)

        expected_document = { 'id' => document.to_gid_param, 'userId' => document.user_id }
        expect(data['node']).to eq(expected_document)
      end
    end
  end

  describe 'type resolution' do
    it 'returns GraphQL error response for unsupported type' do
      execute_graphql('query { specTypeResolutionTest { id } }')

      expect(success?).to be(false)
      expect_data_in_empty
      expect_error_code('INTERNAL_SERVER_ERROR')
      expect_error_message('Internal Server Error')
    end
  end
end

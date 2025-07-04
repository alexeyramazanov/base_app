# frozen_string_literal: true

require 'rails_helper'
require 'shared/graphql'

RSpec.describe PublicGraphqlApi::Queries::NodesQueries do
  let(:user) { create(:user) }

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    test_queries = Module.new do
      extend ActiveSupport::Concern

      included do
        field :spec_type_resolution_test, PublicGraphqlApi::Types::NodeType
      end

      def spec_type_resolution_test
        Class.new.new
      end
    end

    PublicGraphqlApi::Types::QueryType.include(test_queries)
  end

  describe 'nodes query' do
    let!(:user_files) { create_list(:user_file, 2, user:) }
    let!(:other_user_file) { create(:user_file) }

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
        ids: user_files.map(&:to_gid_param)
      }
    end

    it_behaves_like 'authenticated graphql endpoint' do
      let(:query) { super() }
      let(:variables) { super() }
    end

    it_behaves_like 'authorized graphql endpoint' do
      let(:query) { super() }
      let(:user) { super() }
      let(:variables) { { ids: [user_files.first.to_gid_param, other_user_file.to_gid_param] } }
    end

    it_behaves_like 'graphql endpoint validating ID format' do
      let(:query) { super() }
      let(:user) { super() }
      let(:variables) { { ids: [user_files.first.to_gid_param, 'invalid'] } }
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
              ... on File {
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

        expected_user_files = user_files.map { |d| { 'id' => d.to_gid_param, 'userId' => d.user_id } }
        expect(data['nodes']).to match_array(expected_user_files)
      end
    end
  end

  describe 'node query' do
    let!(:user_file) { create(:user_file, user:) }
    let!(:other_user_file) { create(:user_file) }

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
        id: user_file.to_gid_param
      }
    end

    it_behaves_like 'authenticated graphql endpoint' do
      let(:query) { super() }
      let(:variables) { super() }
    end

    it_behaves_like 'authorized graphql endpoint' do
      let(:query) { super() }
      let(:user) { super() }
      let(:variables) { { id: other_user_file.to_gid_param } }
    end

    it_behaves_like 'graphql endpoint validating ID format' do
      let(:query) { super() }
      let(:user) { super() }
      let(:variables) { { id: 'invalid' } }
    end

    it 'returns the correct node for given ID' do
      execute_graphql(query, user, variables)

      expect(success?).to be(true)
      expect(data['node']['id']).to eq(user_file.to_gid_param)
    end

    context 'with File type' do
      let(:query) do
        <<~GQL
          query($id: ID!) {
            node(id: $id) {
              id
              ... on File {
                id
                userId
              }
            }
          }
        GQL
      end
      let(:variables) do
        {
          id: user_file.to_gid_param
        }
      end

      it 'returns fields for specified types' do
        execute_graphql(query, user, variables)

        expect(success?).to be(true)

        expected_user_file = { 'id' => user_file.to_gid_param, 'userId' => user_file.user_id }
        expect(data['node']).to eq(expected_user_file)
      end
    end

    context 'with Version type' do
      let(:current_version) { PublicGraphqlApi::Version.new }

      let(:query) do
        <<~GQL
          query($id: ID!) {
            node(id: $id) {
              id
              ... on Version {
                id
                version
                createdAt
                updatedAt
              }
            }
          }
        GQL
      end
      let(:variables) do
        {
          id: current_version.to_gid_param
        }
      end

      it 'returns fields for specified types' do
        execute_graphql(query, user, variables)

        expect(success?).to be(true)

        expected_user_file = {
          'id'        => current_version.to_gid_param,
          'version'   => current_version.version,
          'createdAt' => current_version.created_at.iso8601,
          'updatedAt' => current_version.updated_at.iso8601
        }
        expect(data['node']).to eq(expected_user_file)
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

# frozen_string_literal: true

require 'rails_helper'
require 'shared/graphql'

RSpec.describe PublicGraphqlApi::Queries::FilesQueries do
  let(:user) { create(:user) }

  describe 'files query' do
    let!(:user_files) { create_list(:user_file, 3, user:) }
    let!(:other_user_files) { create_list(:user_file, 2) } # rubocop:disable RSpec/LetSetup

    let(:query) do
      <<~GQL
        query {
          files {
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
          files(first: 2) {
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
          files {
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

    it 'returns an ordered list of user files' do
      execute_graphql(query, user)

      expect(success?).to be(true)

      expected_user_file_ids = user.user_files.order(id: :desc).map(&:to_gid_param)
      received_user_file_ids = data['files']['nodes'].map { |d| d['id'] }
      expect(received_user_file_ids).to eq(expected_user_file_ids)
    end

    it 'supports pagination' do
      execute_graphql(paginated_query, user)

      expect(success?).to be(true)
      expect(data['files']['nodes'].length).to eq(2)
      expect(data['files']['pageInfo']['hasNextPage']).to be(true)
    end

    it 'supports edges' do
      execute_graphql(edges_query, user)

      expect(success?).to be(true)

      expected_user_file_ids = user_files.map(&:to_gid_param)
      received_user_file_ids = data['files']['edges'].map { |d| d['node']['id'] }
      expect(received_user_file_ids).to match_array(expected_user_file_ids)

      expected_cursors = %w[1 2 3]
      received_cursors = data['files']['edges'].map { |d| Base64.decode64(d['cursor']) }
      expect(received_cursors).to match_array(expected_cursors)
    end
  end

  describe 'file query' do
    let!(:user_file) { create(:user_file, user:) }
    let!(:other_user_file) { create(:user_file) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          file(id: $id) {
            id
            type
            userId
            url
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

    it 'returns a specific user file' do
      execute_graphql(query, user, variables)

      expect(success?).to be(true)

      expected_data = {
        'id'     => user_file.to_gid_param,
        'type'   => PublicGraphqlApi::Types::FileTypeType.image,
        'userId' => user.id,
        'url'    => user_file.attachment.url
      }
      expect(data['file']).to eq(expected_data)
    end
  end
end

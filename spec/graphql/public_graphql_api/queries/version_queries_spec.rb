# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicGraphqlApi::Queries::VersionQueries do
  describe 'version query' do
    let(:query) do
      <<~GQL
        query {
          version {
            version
          }
        }
      GQL
    end

    it 'returns the API version information' do
      execute_graphql(query)

      expect(success?).to be(true)
      expect(data['version']['version']).to eq('1.0.0')
    end
  end
end

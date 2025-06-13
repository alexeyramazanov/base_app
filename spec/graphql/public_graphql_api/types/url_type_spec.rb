# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicGraphqlApi::Types::UrlType do
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    test_queries = Module.new do
      extend ActiveSupport::Concern

      included do
        field :spec_types_url_string_test, PublicGraphqlApi::Types::UrlType
        field :spec_types_uri_object_test, PublicGraphqlApi::Types::UrlType
        field :spec_types_url_argument_test, PublicGraphqlApi::Types::UrlType do
          argument :url, PublicGraphqlApi::Types::UrlType, required: true
        end
      end

      def spec_types_url_string_test
        'https://example.com'
      end

      def spec_types_uri_object_test
        URI.parse('https://example.com')
      end

      def spec_types_url_argument_test(url:)
        url
      end
    end

    PublicGraphqlApi::Types::QueryType.include(test_queries)
  end

  describe 'as a result' do
    context 'with a regular string' do
      let(:query) { 'query { specTypesUrlStringTest }' }

      it 'returns a string' do
        execute_graphql(query)

        expect(success?).to be(true)
        expect(data['specTypesUrlStringTest']).to eq('https://example.com')
      end
    end

    context 'with a URI object' do
      let(:query) { 'query { specTypesUriObjectTest }' }

      it 'returns a string' do
        execute_graphql(query)

        expect(success?).to be(true)
        expect(data['specTypesUriObjectTest']).to eq('https://example.com')
      end
    end
  end

  describe 'as an argument' do
    let(:query) do
      <<~GQL
        query($url: Url!) {
          specTypesUrlArgumentTest(url: $url)
        }
      GQL
    end

    context 'with a valid URL' do
      let(:variables) { { url: 'https://example.com' } }

      it 'returns the URL' do
        execute_graphql(query, nil, variables)

        expect(success?).to be(true)
        expect(data['specTypesUrlArgumentTest']).to eq('https://example.com')
      end
    end

    context 'with an invalid URL' do
      let(:variables) { { url: 'example.com' } }

      it 'returns nil' do
        execute_graphql(query, nil, variables)

        expect(success?).to be(false)
        expect_data_in_empty
        expect_error_message('Variable $url of type Url! was provided invalid value')
      end
    end
  end
end

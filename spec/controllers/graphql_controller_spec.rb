# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraphqlController do
  describe 'POST #execute' do
    context 'with valid query' do
      let(:query) do
        <<~GQL
          query TestOperation($name: String!) {
            __type(name: $name) {
              name
              kind
            }
          }
        GQL
      end
      let(:variables) { { 'name' => 'ID' } }
      let(:operation_name) { 'TestOperation' }

      it 'executes the query and returns json response' do
        post :execute, params: {
          query:         query,
          variables:     variables,
          operationName: operation_name
        }

        expect(response).to be_successful
        expect(response.content_type).to include('application/json')

        data = JSON.parse(response.body)
        expect(data['data']['__type']['name']).to eq('ID')
        expect(data['data']['__type']['kind']).to eq('SCALAR')
      end
    end

    context 'with invalid query' do
      let(:query) { 'invalid query' }

      it 'returns json error response' do
        post :execute, params: { query: query }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')

        data = JSON.parse(response.body)
        expect(data['errors']).to be_present
      end
    end
  end

  describe '#prepare_variables' do
    it 'handles string variables' do
      json_variables = '{"test": "value"}'
      result = controller.send(:prepare_variables, json_variables)

      expect(result).to eq({ 'test' => 'value' })
    end

    it 'handles empty string variables' do
      result = controller.send(:prepare_variables, '')

      expect(result).to eq({})
    end

    it 'handles hash variables' do
      hash_variables = { 'test' => 'value' }
      result = controller.send(:prepare_variables, hash_variables)

      expect(result).to eq(hash_variables)
    end

    it 'handles nil variables' do
      result = controller.send(:prepare_variables, nil)

      expect(result).to eq({})
    end

    it 'handles ActionController::Parameters' do
      params = ActionController::Parameters.new({ 'test' => 'value' })
      result = controller.send(:prepare_variables, params)

      expect(result).to eq({ 'test' => 'value' })
    end

    it 'raises ArgumentError for unexpected parameter types' do
      expect { controller.send(:prepare_variables, 123) }.to raise_error(ArgumentError, 'Unexpected parameter: 123')
    end
  end
end

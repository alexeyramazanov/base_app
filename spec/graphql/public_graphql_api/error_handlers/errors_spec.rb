# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicGraphqlApi::ErrorHandlers::Errors do
  subject(:test_class) { test_class_definition.new }

  let(:test_class_definition) do
    Class.new do
      include PublicGraphqlApi::ErrorHandlers::Errors
    end
  end

  let(:test_model) do
    Class.new do
      include ActiveModel::API

      attr_accessor :email, :password

      validates :email, presence: true
      validates :password, length: { minimum: 6 }

      def self.model_name
        ActiveModel::Name.new(self, nil, 'PublicGraphqlApiErrorHandlersErrorsTestModel')
      end
    end
  end

  describe '#raise_model_validation_error!' do
    let(:record) do
      record = test_model.new
      record.valid?
      record
    end

    it 'raises GraphQL::ExecutionError with correct details' do
      expect { test_class.raise_model_validation_error!(record) }.to raise_error(GraphQL::ExecutionError) do |error|
        expect(error.message).to eq('Validation Error')
        expect(error.extensions[:code]).to eq('VALIDATION_ERROR')
        expect(error.extensions[:details]).to contain_exactly(
          { field: 'email', message: "can't be blank" },
          { field: 'password', message: 'is too short (minimum is 6 characters)' }
        )
      end
    end
  end

  describe '#raise_simple_validation_error!' do
    let(:errors) { ['Invalid input', 'Something went wrong'] }

    it 'raises GraphQL::ExecutionError with correct details' do
      expect { test_class.raise_simple_validation_error!(errors) }.to raise_error(GraphQL::ExecutionError) do |error|
        expect(error.message).to eq('Validation Error')
        expect(error.extensions[:code]).to eq('VALIDATION_ERROR')
        expect(error.extensions[:details]).to contain_exactly(
          { field: nil, message: 'Invalid input' },
          { field: nil, message: 'Something went wrong' }
        )
      end
    end
  end

  describe '#raise_record_not_found_error!' do
    it 'raises GraphQL::ExecutionError with NOT_FOUND code' do
      expect { test_class.raise_record_not_found_error! }.to raise_error(GraphQL::ExecutionError) do |error|
        expect(error.message).to eq('Not Found')
        expect(error.extensions[:code]).to eq('NOT_FOUND')
      end
    end
  end

  describe '#raise_unauthenticated_error!' do
    it 'raises GraphQL::ExecutionError with UNAUTHENTICATED code' do
      expect { test_class.raise_unauthenticated_error! }.to raise_error(GraphQL::ExecutionError) do |error|
        expect(error.message).to eq('Unauthenticated')
        expect(error.extensions[:code]).to eq('UNAUTHENTICATED')
      end
    end
  end

  describe '#raise_unauthorized_error!' do
    it 'raises GraphQL::ExecutionError with UNAUTHORIZED code' do
      expect { test_class.raise_unauthorized_error! }.to raise_error(GraphQL::ExecutionError) do |error|
        expect(error.message).to eq('Unauthorized')
        expect(error.extensions[:code]).to eq('UNAUTHORIZED')
      end
    end
  end

  describe '#raise_internal_server_error!' do
    let(:error) do
      err = StandardError.new('error')
      err.set_backtrace(['line 1', 'line 2'])
      err
    end

    it 'raises GraphQL::ExecutionError with INTERNAL_SERVER_ERROR code' do
      expect { test_class.raise_internal_server_error!(error) }.to raise_error(GraphQL::ExecutionError) do |error|
        expect(error.message).to eq('Internal Server Error')
        expect(error.extensions[:code]).to eq('INTERNAL_SERVER_ERROR')
      end
    end

    it 'logs the error in development environment' do
      allow(Rails.env).to receive(:development?).and_return(true)
      allow(Rails.logger).to receive(:error)

      expect { test_class.raise_internal_server_error!(error) }.to raise_error(GraphQL::ExecutionError)

      expect(Rails.logger).to have_received(:error).with('error')
      expect(Rails.logger).to have_received(:error).with("line 1\nline 2")
    end
  end
end

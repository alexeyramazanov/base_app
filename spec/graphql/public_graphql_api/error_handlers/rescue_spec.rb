# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicGraphqlApi::ErrorHandlers::Rescue do
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    test_type = Class.new(PublicGraphqlApi::Types::BaseObject) do
      graphql_name 'PublicGraphqlApiErrorHandlersRescueAuthorizationTestType'

      field :status, GraphQL::Types::Boolean

      def self.authorized?(_object, _context)
        false
      end
    end

    test_queries = Module.new do
      extend ActiveSupport::Concern

      included do
        field :spec_rescue_record_not_found_test, GraphQL::Types::Boolean
        field :spec_rescue_pundit_authorization_test, GraphQL::Types::Boolean
        field :spec_rescue_generic_exception_test, GraphQL::Types::Boolean
        field :spec_unauthorized_object_test, test_type
        field :spec_unauthorized_field_test, Integer do
          def authorized?(_object, _args, _context)
            false
          end
        end
      end

      def spec_rescue_record_not_found_test
        raise ActiveRecord::RecordNotFound, 'not found'
      end

      def spec_rescue_pundit_authorization_test
        raise Pundit::NotAuthorizedError, 'error'
      end

      def spec_rescue_generic_exception_test
        raise StandardError, 'error'
      end

      def spec_unauthorized_object_test
        { status: true }
      end
    end

    PublicGraphqlApi::Types::QueryType.include(test_queries)

    # Since GraphQL schema is not dynamic - it builds structure on the 1st call (in dev)/application load (in prod),
    # and since we are basically monkey patching the existing schema by including new module for testing,
    # we have to add missing references manually.
    # Otherwise, in envs with enabled `eager_load` (prod, CI test) we'll get "Field '...' doesn't exist on type 'Query'"
    # because GraphQL won't be able to find referenced response field.
    # ap PublicGraphqlApi::BaseAppSchema.send(:own_references_to)
    PublicGraphqlApi::BaseAppSchema.send(:own_references_to)[test_type] =
      [PublicGraphqlApi::BaseAppSchema.query.fields['specUnauthorizedObjectTest']]
  end

  describe 'ActiveRecord::RecordNotFound exception processing' do
    it 'returns GraphQL error response' do
      execute_graphql('query { specRescueRecordNotFoundTest }')

      expect(success?).to be(false)
      expect_data_in_empty
      expect_error_code('NOT_FOUND')
      expect_error_message('Not Found')
    end
  end

  describe 'Pundit::NotAuthorizedError exception processing' do
    it 'returns GraphQL error response' do
      execute_graphql('query { specRescuePunditAuthorizationTest }')

      expect(success?).to be(false)
      expect_data_in_empty
      expect_error_code('UNAUTHORIZED')
      expect_error_message('Unauthorized')
    end
  end

  describe 'other exceptions processing' do
    it 'returns GraphQL error response' do
      execute_graphql('query { specRescueGenericExceptionTest }')

      expect(success?).to be(false)
      expect_data_in_empty
      expect_error_code('INTERNAL_SERVER_ERROR')
      expect_error_message('Internal Server Error')
    end
  end

  describe 'failed object authorization processing' do
    it 'returns GraphQL error response' do
      execute_graphql('query { specUnauthorizedObjectTest { status } }')

      expect(success?).to be(false)
      expect_data_in_empty
      expect_error_code('UNAUTHORIZED')
      expect_error_message('Unauthorized')
    end
  end

  describe 'failed field authorization processing' do
    it 'returns valid response but without requested field' do
      execute_graphql('query { specUnauthorizedFieldTest }')

      expect(success?).to be(true)
      expect(data['specUnauthorizedFieldTest']).to be_nil
    end
  end
end

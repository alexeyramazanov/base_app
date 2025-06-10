# frozen_string_literal: true

require 'rails_helper'

class PublicGraphqlApiErrorHandlersRescueAuthorizationTestType < PublicGraphqlApi::Types::BaseObject
  field :status, GraphQL::Types::Boolean

  def self.authorized?(_object, _context)
    false
  end
end

module PublicGraphqlApiErrorHandlersRescueTest
  extend ActiveSupport::Concern

  included do
    field :spec_rescue_record_not_found_test, GraphQL::Types::Boolean
    field :spec_rescue_pundit_authorization_test, GraphQL::Types::Boolean
    field :spec_rescue_generic_exception_test, GraphQL::Types::Boolean
    field :spec_unauthorized_object_test, PublicGraphqlApiErrorHandlersRescueAuthorizationTestType
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
    5
  end
end

module PublicGraphqlApi
  module Types
    class QueryType
      include PublicGraphqlApiErrorHandlersRescueTest
    end
  end
end

RSpec.describe PublicGraphqlApi::ErrorHandlers::Rescue do
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

# frozen_string_literal: true

module GraphqlHelper
  def execute_graphql(query, user = nil, variables = {})
    context = {
      current_user: user
    }

    @gql_response = PublicGraphqlApi::BaseAppSchema.execute(query, variables:, context:)
  end

  def response
    @gql_response
  end

  def data
    response['data']
  end

  def errors
    response['errors']
  end

  def success?
    errors.blank?
  end

  # checking 2 possible cases here:
  # - if a query field is allowed to be `null` - graphql-ruby does not remove this field from the response,
  #   it just keeps its value `null`
  # - if a query field is not allowed to be `null` - graphql-ruby completely removes this field from the response
  def expect_data_in_empty
    return if data.nil?

    errors.each do |error|
      expect(data.dig(*error['path'])).to be_nil
    end
  end

  def expect_error_code(expected_code)
    expect_errors_codes([expected_code])
  end

  def expect_errors_codes(expected_codes)
    codes = errors.map { |error| error.dig('extensions', 'code') }
    expect(codes).to eq(expected_codes)
  end

  def expect_error_message(expected_message)
    expect_error_messages([expected_message])
  end

  def expect_error_messages(expected_messages)
    messages = errors.map { |error| error['message'] }
    expect(messages).to match_array(expected_messages)
  end

  def expect_validation_errors(expected_errors)
    validation_errors = []

    errors.each do |error|
      next unless error.dig('extensions', 'code') == 'VALIDATION_ERROR'

      validation_errors += error.dig('extensions', 'details')
    end

    expect(validation_errors).to match_array(expected_errors)
  end
end

RSpec.configure do |config|
  config.include GraphqlHelper, type: :graphql

  config.before :each, type: :graphql do
    @gql_response = nil
  end
end

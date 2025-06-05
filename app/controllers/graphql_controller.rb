# frozen_string_literal: true

class GraphqlController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include ApiTokenAuthentication

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user:
    }

    # All exceptions are caught by the `rescue_from` block and wrapped into a valid GraphQL response
    result = PublicGraphqlApi::BaseAppSchema.execute(query, variables:, context:, operation_name:)

    render json: result
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end
end

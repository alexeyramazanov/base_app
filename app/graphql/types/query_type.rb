# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include Helpers::AuthorizationHelpers
    include Errors

    include Queries::DocumentsQueries
  end
end

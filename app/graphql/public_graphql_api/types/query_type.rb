# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class QueryType < Types::BaseObject
      include Helpers::AuthorizationHelpers
      include ErrorHandlers::Errors

      include Queries::NodesQueries
      include Queries::DocumentsQueries
    end
  end
end

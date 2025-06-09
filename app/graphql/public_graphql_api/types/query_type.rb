# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class QueryType < Types::BaseObject
      include ErrorHandlers::Errors
      include Helpers::AuthorizationHelpers

      include Queries::NodesQueries
      include Queries::DocumentsQueries
    end
  end
end

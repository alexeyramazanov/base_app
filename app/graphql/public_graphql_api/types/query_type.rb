# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class QueryType < Types::BaseObject
      include ErrorHandlers::Errors
      include Helpers::AuthHelpers

      include Queries::NodesQueries
      include Queries::VersionQueries

      include Queries::FilesQueries
    end
  end
end

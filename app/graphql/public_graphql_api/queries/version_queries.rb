# frozen_string_literal: true

module PublicGraphqlApi
  module Queries
    module VersionQueries
      extend ActiveSupport::Concern

      included do
        field :version, Types::VersionType, null: false, description: 'Fetches GraphQL API version information'
      end

      def version
        PublicGraphqlApi::Version.new
      end
    end
  end
end

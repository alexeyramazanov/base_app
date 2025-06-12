# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class VersionType < PublicActiveRecordType
      description 'GraphQL API version information.'

      field :version, String, null: false, description: 'The GraphQL API version.'
    end
  end
end

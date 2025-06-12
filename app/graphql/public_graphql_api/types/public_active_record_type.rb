# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class PublicActiveRecordType < BaseObject
      implements NodeType

      field :created_at, GraphQL::Types::ISO8601DateTime, null: true
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    end
  end
end

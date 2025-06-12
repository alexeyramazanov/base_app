# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class PublicActiveRecordType < BaseObject
      implements NodeType
      description 'The object representing publicly available ApplicationRecord.'

      field :created_at, GraphQL::Types::ISO8601DateTime,
            null: true, description: 'The date and time when the object was created.'
      field :updated_at, GraphQL::Types::ISO8601DateTime,
            null: true, description: 'The date and time when the object was last updated.'
    end
  end
end

# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class ActiveRecordType < BaseObject
      implements NodeType

      field :created_at, GraphQL::Types::ISO8601DateTime, null: true
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: true

      # object authorization
      # by default, all objects are authorized by calling `show?` for appropriate policy
      def self.authorized?(object, context)
        Pundit.authorize(context[:current_user], object, :show?) && super
      end
    end
  end
end

# frozen_string_literal: true

module PublicGraphqlApi
  module Queries
    module NodesQueries
      extend ActiveSupport::Concern

      included do
        field :nodes, [Types::NodeType, { null: false }],
              null: false, description: 'Fetches a list of objects given a list of IDs.' do
          argument :ids, [GraphQL::Types::ID], required: true, description: 'IDs of the objects.'
        end

        field :node, Types::NodeType,
              null: false, description: 'Fetches an object given its ID.' do
          argument :id, GraphQL::Types::ID, required: true, description: 'ID of the object.'
        end
      end

      def nodes(ids:)
        authenticate!

        # returns error response even if just one ID on the list is invalid
        ids.map { |id| context.schema.object_from_id(id, context) }
      end

      def node(id:)
        authenticate!

        context.schema.object_from_id(id, context)
      end
    end
  end
end

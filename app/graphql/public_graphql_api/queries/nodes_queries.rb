# frozen_string_literal: true

module PublicGraphqlApi
  module Queries
    module NodesQueries
      extend ActiveSupport::Concern

      included do
        field :nodes, [Types::NodeType, { null: true }],
              null: true, description: 'Fetches a list of objects given a list of IDs.' do
          argument :ids, [GraphQL::Types::ID], required: true, description: 'IDs of the objects.'
        end

        field :node, Types::NodeType,
              null: true, description: 'Fetches an object given its ID.' do
          argument :id, GraphQL::Types::ID, required: true, description: 'ID of the object.'
        end
      end

      def nodes(ids:)
        ids.map { |id| context.schema.object_from_id(id, context) }
      end

      def node(id:)
        context.schema.object_from_id(id, context)
      end
    end
  end
end

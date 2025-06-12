# frozen_string_literal: true

module PublicGraphqlApi
  module Queries
    module DocumentsQueries
      extend ActiveSupport::Concern

      included do
        field :documents, Types::DocumentType.connection_type,
              null: false, description: 'Fetches user documents.'

        field :document, Types::DocumentType, null: false, description: 'Fetches a user document by ID.' do
          argument :id, GraphQL::Types::ID, required: true, description: 'The ID of the document.'
        end
      end

      def documents
        authenticate!

        policy_scope(Document).order(id: :desc)
      end

      def document(id:)
        authenticate!

        context.schema.object_from_id(id, context)
      end
    end
  end
end

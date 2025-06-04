# frozen_string_literal: true

module Queries
  module DocumentsQueries
    extend ActiveSupport::Concern

    included do
      field :documents, Types::DocumentType.connection_type,
            null: false, description: 'Returns a list of documents'

      field :document, Types::DocumentType, null: true, description: 'Returns a document' do
        argument :id, GraphQL::Schema::Member::GraphQLTypeNames::ID,
                 required: true, description: 'The ID of the document'
      end
    end

    def documents
      policy_scope(Document).order(id: :desc)
    end

    def document(id:)
      policy_scope(Document).find(id)
    end
  end
end

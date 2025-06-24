# frozen_string_literal: true

module PublicGraphqlApi
  module Queries
    module FilesQueries
      extend ActiveSupport::Concern

      included do
        field :files, Types::FileType.connection_type,
              null: false, description: 'Fetches user files.'

        field :file, Types::FileType, null: false, description: 'Fetches a user file by ID.' do
          argument :id, GraphQL::Types::ID, required: true, description: 'The ID of the user file.'
        end
      end

      def files
        authenticate!

        policy_scope(UserFile).order(id: :desc)
      end

      def file(id:)
        authenticate!

        context.schema.object_from_id(id, context)
      end
    end
  end
end

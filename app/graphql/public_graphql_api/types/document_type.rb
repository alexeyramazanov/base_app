# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class DocumentType < ActiveRecordType
      field :user_id, ID, null: false # TODO: relation
      field :file_name, String, null: false
      field :file_size, String, null: false

      def file_name
        object.file.metadata['filename']
      end

      def file_size
        object.file.metadata['size']
      end
    end
  end
end

# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class DocumentType < ActiveRecordType
      description 'The user document.'

      field :file_name, String, null: false, description: 'The file name of the document.'
      field :file_size, Integer, null: false, description: 'The file size of the document.' # rubocop:disable GraphQL/ExtractType
      field :type, DocumentTypeType, null: false, description: 'The type of the document.'
      field :user_id, Integer, null: false, description: 'The ID of the user which owns the document.' # TODO: relation
      # NOTE: dev/test envs could use a local FS as a storage, meaning URLs to files will be technically invalid
      field :url, UrlType, null: false, description: 'The URL for downloading the document.'

      def type
        # NOTE: right now we accept only images
        DocumentTypeType.image
      end

      def file_name
        object.file.metadata['filename']
      end

      def file_size
        object.file.metadata['size']
      end

      def url
        object.file.url
      end
    end
  end
end

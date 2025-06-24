# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class FileType < ActiveRecordType
      description 'The user file.'

      field :file_name, String, null: false, description: 'The name of the file.'
      field :file_size, Integer, null: false, description: 'The size of the file.' # rubocop:disable GraphQL/ExtractType
      field :type, FileTypeType, null: false, description: 'The type of the file.'
      field :user_id, Integer, null: false, description: 'The ID of the user which owns the file.' # TODO: relation
      # NOTE: dev/test envs could use a local FS as a storage, meaning URLs to files will be technically invalid
      field :url, UrlType, null: false, description: 'The URL for downloading the file.'

      def type
        # TODO: fix
        FileTypeType.image
      end

      def file_name
        object.attachment.original_filename
      end

      def file_size
        object.attachment.size
      end

      def url
        object.attachment.url
      end
    end
  end
end

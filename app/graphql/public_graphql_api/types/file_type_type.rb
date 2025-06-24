# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class FileTypeType < BaseEnum
      description 'The type of a file.'

      value 'IMAGE', 'Image', description: 'Image.'
      value 'DOCUMENT', 'Document', description: 'Document.'
      value 'UNKNOWN', 'Unknown', description: 'Unknown.'
    end
  end
end

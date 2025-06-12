# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class DocumentTypeType < BaseEnum
      description 'The type of a document.'

      value 'IMAGE', 'Image', description: 'Image.'
    end
  end
end

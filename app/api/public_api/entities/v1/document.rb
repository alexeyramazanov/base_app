# frozen_string_literal: true

module PublicApi
  module Entities
    module V1
      class Document < Grape::Entity
        expose :id, documentation: { type: 'integer', desc: 'Document ID', example: 241 }
        expose :user_id, documentation: { type: 'integer', desc: 'User ID', example: 15 }
        expose :file_name, documentation: { type: 'string', desc: 'File name', example: 'image.png' }

        private

        def file_name
          object.file.metadata['filename']
        end
      end
    end
  end
end

# frozen_string_literal: true

module PublicRestApi
  module Entities
    module V2
      class Document < Grape::Entity
        expose :id, documentation: { type: 'integer', desc: 'Document ID', example: 241 }
        expose :user_id, documentation: { type: 'integer', desc: 'User ID', example: 15 }
        expose :file_name, documentation: { type: 'string', desc: 'File name', example: 'image.png' }
        expose :file_size, documentation: { type: 'integer', desc: 'File size', example: 78_325 }

        private

        def file_name
          object.file.metadata['filename']
        end

        def file_size
          object.file.metadata['size']
        end
      end
    end
  end
end

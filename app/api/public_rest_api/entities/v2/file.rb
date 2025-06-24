# frozen_string_literal: true

module PublicRestApi
  module Entities
    module V2
      class File < Grape::Entity
        expose :id, documentation: { type: 'integer', desc: 'File ID', example: 241 }
        expose :user_id, documentation: { type: 'integer', desc: 'User ID', example: 15 }
        expose :file_name, documentation: { type: 'string', desc: 'File name', example: 'image.png' }
        expose :file_size, documentation: { type: 'integer', desc: 'File size', example: 78_325 }

        private

        def file_name
          object.attachment.original_filename
        end

        def file_size
          object.attachment.size
        end
      end
    end
  end
end

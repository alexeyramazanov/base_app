# frozen_string_literal: true

module PublicApi
  module Entities
    module V2
      class Document < Grape::Entity
        expose :id, documentation: { type: 'integer', desc: 'Document ID' }
        expose :user_id, documentation: { type: 'integer', desc: 'User ID' }
        expose :file_name, documentation: { type: 'string', desc: 'File name' }
        expose :file_size, documentation: { type: 'integer', desc: 'File size' }

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

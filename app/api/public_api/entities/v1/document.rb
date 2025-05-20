# frozen_string_literal: true

module PublicApi
  module Entities
    module V1
      class Document < Grape::Entity
        expose :id, documentation: { type: 'integer', desc: 'Document ID' }
        expose :user_id, documentation: { type: 'integer', desc: 'User ID' }
        expose :file_name, documentation: { type: 'string', desc: 'File name' }

        private

        def file_name
          object.file.metadata['filename']
        end
      end
    end
  end
end

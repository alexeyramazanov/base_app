# frozen_string_literal: true

module PublicRestApi
  module Entities
    module V1
      class FileDownload < Grape::Entity
        expose :id, documentation: { type: 'integer', desc: 'Document ID', example: 241 }
        expose :url, documentation: { type: 'string', desc: 'Download URL', example: 'https://bucket.s3.us-east-1.amazonaws.com/documents/image.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&...' }

        private

        def url
          object.attachment.url
        end
      end
    end
  end
end

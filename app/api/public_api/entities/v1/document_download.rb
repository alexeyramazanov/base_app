# frozen_string_literal: true

module PublicApi
  module Entities
    module V1
      class DocumentDownload < Grape::Entity
        expose :id, documentation: { type: 'integer', desc: 'Document ID' }
        expose :url, documentation: { type: 'string', desc: 'Download URL' }

        private

        def url
          object.file.url
        end
      end
    end
  end
end

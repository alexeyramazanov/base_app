# frozen_string_literal: true

module PublicRestApi
  module Entities
    module V2
      class PaginatedDocuments < PaginatedEntity
        expose :records, using: Document, override: true, documentation: { is_array: true }
      end
    end
  end
end

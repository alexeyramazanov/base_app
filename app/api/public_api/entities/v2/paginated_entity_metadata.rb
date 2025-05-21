# frozen_string_literal: true

module PublicApi
  module Entities
    module V2
      class PaginatedEntityMetadata < Grape::Entity
        expose :current_page, documentation: { type: 'integer', desc: 'Current page number' }
        expose :per_page, documentation: { type: 'integer', desc: 'Number of records per page' }
        expose :total_pages, documentation: { type: 'integer', desc: 'Total number of pages' }
        expose :total_count, documentation: { type: 'integer', desc: 'Total number of records' }
      end
    end
  end
end

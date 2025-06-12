# frozen_string_literal: true

module PublicRestApi
  module Entities
    module V2
      class PaginatedEntityMetadata < Grape::Entity
        expose :current_page, documentation: { type: 'integer', desc: 'Current page number', example: 2 }
        expose :per_page, documentation: { type: 'integer', desc: 'Number of records per page', example: 10 }
        expose :total_pages, documentation: { type: 'integer', desc: 'Total number of pages', example: 5 }
        expose :total_count, documentation: { type: 'integer', desc: 'Total number of records', example: 43 }
      end
    end
  end
end

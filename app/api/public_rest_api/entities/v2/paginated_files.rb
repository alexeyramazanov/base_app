# frozen_string_literal: true

module PublicRestApi
  module Entities
    module V2
      class PaginatedFiles < PaginatedEntity
        expose :records, using: File, override: true, documentation: { is_array: true }
      end
    end
  end
end

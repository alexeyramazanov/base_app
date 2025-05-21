# frozen_string_literal: true

module PublicApi
  module Entities
    module V2
      class PaginatedEntity < Grape::Entity
        expose :records, documentation: { is_array: true }
        expose :metadata, using: PaginatedEntityMetadata
      end
    end
  end
end

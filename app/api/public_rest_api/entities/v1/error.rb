# frozen_string_literal: true

module PublicRestApi
  module Entities
    module V1
      class Error < Grape::Entity
        expose :code, documentation: { type: 'integer', desc: 'Error code' }
        expose :message, documentation: { type: 'string', desc: 'Error message' }
        expose :errors, default: [], documentation: { type: 'string', is_array: true, desc: 'Error details' }
      end
    end
  end
end

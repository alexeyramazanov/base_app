# frozen_string_literal: true

module PublicGraphqlApi
  module Mutations
    module DocumentsMutations
      extend ActiveSupport::Concern

      included do
        field :create_document,
              mutation:    Mutations::DocumentsMutations::CreateDocument,
              description: 'Creates a new user document.'
      end
    end
  end
end

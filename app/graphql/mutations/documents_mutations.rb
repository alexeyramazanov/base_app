# frozen_string_literal: true

module Mutations
  module DocumentsMutations
    extend ActiveSupport::Concern

    included do
      field :create_document, mutation: Mutations::DocumentsMutations::CreateDocument
    end
  end
end

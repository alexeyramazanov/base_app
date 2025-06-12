# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class MutationType < Types::BaseObject
      include Mutations::DocumentsMutations
    end
  end
end

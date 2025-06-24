# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class MutationType < Types::BaseObject
      include Mutations::FilesMutations
    end
  end
end

# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class BaseInputObject < GraphQL::Schema::InputObject
      argument_class Types::BaseArgument
    end
  end
end

# frozen_string_literal: true

module PublicGraphqlApi
  module Mutations
    class BaseMutation < GraphQL::Schema::RelayClassicMutation
      include Helpers::AuthHelpers
      include ErrorHandlers::Errors

      argument_class Types::BaseArgument
      field_class Types::BaseField
      input_object_class Types::BaseInputObject
      object_class Types::BaseObject
    end
  end
end

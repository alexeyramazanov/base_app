# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class BaseEnum < GraphQL::Schema::Enum
      value_methods true
    end
  end
end

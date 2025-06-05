# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    module NodeType
      include Types::BaseInterface
      include GraphQL::Types::Relay::NodeBehaviors
    end
  end
end

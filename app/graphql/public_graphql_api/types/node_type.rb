# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    module NodeType
      description 'A globally unique object in the system that implements the Relay `Node` interface.'

      include Types::BaseInterface
      include GraphQL::Types::Relay::NodeBehaviors
    end
  end
end

# frozen_string_literal: true

module PublicGraphqlApi
  module Mutations
    module FilesMutations
      extend ActiveSupport::Concern

      included do
        field :create_file,
              mutation:    Mutations::FilesMutations::CreateFile,
              description: 'Creates a new user file.'
      end
    end
  end
end

# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class BaseField < GraphQL::Schema::Field
      include ErrorHandlers::Errors

      argument_class Types::BaseArgument

      def initialize(*args, authorize: nil, **kwargs, &block)
        @authorize = authorize

        super(*args, **kwargs, &block)
      end

      # queries/mutations/individual fields authorization (authorization is skipped by default)
      def authorized?(object, args, context)
        Pundit.authorize(context[:current_user], object, @authorize) if @authorize

        super
      end
    end
  end
end

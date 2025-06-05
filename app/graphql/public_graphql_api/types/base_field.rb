# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class BaseField < GraphQL::Schema::Field
      include ErrorHandlers::Errors

      argument_class Types::BaseArgument

      def initialize(*args, authenticate: true, authorize: nil, **kwargs, &block)
        @authenticate = authenticate
        @authorize = authorize

        super(*args, **kwargs, &block)
      end

      # queries/mutations/individual fields authentication/authorization
      # by default, everything is authenticated (authorization is optional)
      def authorized?(object, args, context)
        raise_unauthenticated_error! if @authenticate && context[:current_user].blank?

        Pundit.authorize(context[:current_user], object, @authorize) if @authorize

        super
      end
    end
  end
end

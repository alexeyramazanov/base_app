# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class BaseArgument < GraphQL::Schema::Argument
      def initialize(*args, authorize: nil, **kwargs, &block)
        @authorize = authorize

        super(*args, **kwargs, &block)
      end

      # argument authorization
      # by default, arguments do not perform authorization
      def authorized?(obj, arg_value, ctx)
        Pundit.authorize(ctx[:current_user], obj, @authorize) if @authorize

        super
      end
    end
  end
end

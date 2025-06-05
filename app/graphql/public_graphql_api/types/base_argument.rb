# frozen_string_literal: true

module PublicGraphqlApi
  module Types
    class BaseArgument < GraphQL::Schema::Argument
      def initialize(*args, authorize: nil, policy_class: nil, **kwargs, &block)
        @authorize = authorize
        @policy_class = policy_class

        super(*args, **kwargs, &block)
      end

      # argument authorization
      # by default, arguments do not perform authorization
      def authorized?(obj, arg_value, ctx)
        if @authorize && @policy_class
          # TODO: do we need policy_class?
          super && Pundit.authorize(ctx[:current_user], obj, @authorize, policy_class: @policy_class)
        else
          super
        end
      end
    end
  end
end

# frozen_string_literal: true

module PublicGraphqlApi
  module Helpers
    module AuthHelpers
      include Pundit::Authorization

      def authenticate!
        raise_unauthenticated_error! unless current_user
      end

      def current_user
        context[:current_user]
      end
    end
  end
end

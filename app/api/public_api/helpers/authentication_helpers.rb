# frozen_string_literal: true

module PublicApi
  module Helpers
    module AuthenticationHelpers
      def authenticate!
        return if public_route?

        # Bearer <token>
        token = headers['Authorization'].to_s.split(' ').last
        api_token = ApiToken.find_by(token:)

        error_unauthorized! unless api_token

        api_token.used_now!
        @current_user = api_token.user
      end

      def current_user
        @current_user
      end

      private

      def public_route?
        PublicApi::Root::PUBLIC_ROUTES.include?(request.path)
      end
    end
  end
end

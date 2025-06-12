# frozen_string_literal: true

module PublicRestApi
  module Helpers
    module AuthenticationHelpers
      def authenticate!
        return if public_route?

        # Bearer <token>
        token = headers['Authorization'].to_s.split(' ').last
        api_token = token.present? ? ApiToken.find_by(token:) : nil

        error_unauthorized! unless api_token

        api_token.used_now!
        @current_user = api_token.user
      end

      def current_user
        @current_user
      end

      private

      def public_route?
        PublicRestApi::Root::PUBLIC_ROUTES.include?(request.path)
      end
    end
  end
end

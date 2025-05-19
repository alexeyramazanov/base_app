# frozen_string_literal: true

module PublicApi
  module Helpers
    module AuthenticationHelper
      def authenticate!
        token = headers['Authorization'].split(' ').last
        api_token = ApiToken.find_by(token:)

        error_not_authenticated! unless api_token

        api_token.used_now!
        @current_user = api_token.user
      end

      def current_user
        @current_user
      end
    end
  end
end

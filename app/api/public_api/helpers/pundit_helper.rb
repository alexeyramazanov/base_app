# frozen_string_literal: true

module PublicApi
  module Helpers
    module PunditHelper
      include Pundit::Authorization

      def verify_pundit_authorization!
        error_forbidden! if !pundit_policy_authorized? && !pundit_policy_scoped? && !public_route?
      end
    end
  end
end

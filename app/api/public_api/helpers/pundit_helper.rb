# frozen_string_literal: true

module PublicApi
  module Helpers
    module PunditHelper
      include Pundit::Authorization

      def verify_pundit_authorization!
        error_pundit_not_authorized! if !pundit_policy_authorized? && !pundit_policy_scoped?
      end
    end
  end
end

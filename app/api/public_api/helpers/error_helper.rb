# frozen_string_literal: true

module PublicApi
  module Helpers
    module ErrorHelper
      def error_not_authenticated!
        error!('Not Authorized', 401)
      end

      def error_pundit_not_authorized!
        error!('Pundit Not Authorized', 500)
      end
    end
  end
end

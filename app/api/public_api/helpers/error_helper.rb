# frozen_string_literal: true

module PublicApi
  module Helpers
    module ErrorHelper
      def failures(*codes)
        codes.map do |code|
          errors = (code == 422) ? ['Invalid value for field "name"'] : []

          {
            code:     code,
            message:  Rack::Utils::HTTP_STATUS_CODES[code],
            model:    Entities::V1::Error,
            examples: {
              'application/json': {
                code:    code,
                message: Rack::Utils::HTTP_STATUS_CODES[code],
                errors:  errors
              }
            }
          }
        end
      end

      def error_unauthorized!
        error!({ code: 401, message: Rack::Utils::HTTP_STATUS_CODES[401], with: Entities::V1::Error }, 401)
      end

      def error_forbidden!
        error!({ code: 403, message: Rack::Utils::HTTP_STATUS_CODES[403], with: Entities::V1::Error }, 403)
      end

      def error_not_found!
        error!({ code: 404, message: Rack::Utils::HTTP_STATUS_CODES[404], with: Entities::V1::Error }, 404)
      end

      def error_unprocessable_entity!(*errors)
        error!(
          { code: 422, message: Rack::Utils::HTTP_STATUS_CODES[422], errors: errors, with: Entities::V1::Error },
          422
        )
      end

      def internal_server_error!
        error!({ code: 500, message: Rack::Utils::HTTP_STATUS_CODES[500], with: Entities::V1::Error }, 500)
      end

      def log_exception(exception)
        Rails.logger.error "\n\n#{exception.class} (#{exception.message}):"
        Rails.logger.error exception.backtrace.join("\n")
      end
    end
  end
end

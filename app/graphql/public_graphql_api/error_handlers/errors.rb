# frozen_string_literal: true

module PublicGraphqlApi
  module ErrorHandlers
    module Errors
      def raise_model_validation_error!(record)
        details = record.errors.map do |error|
          {
            field:   error.attribute.to_s.camelize(:lower),
            message: error.message
          }
        end

        raise_validation_error!(details)
      end

      def raise_simple_validation_error!(errors)
        details = errors.map do |error|
          {
            field:   nil,
            message: error
          }
        end

        raise_validation_error!(details)
      end

      def raise_record_not_found_error!
        raise GraphQL::ExecutionError.new('Not Found', extensions: { code: 'NOT_FOUND' })
      end

      def raise_unauthenticated_error!
        raise GraphQL::ExecutionError.new('Unauthenticated', extensions: { code: 'UNAUTHENTICATED' })
      end

      def raise_unauthorized_error!
        raise GraphQL::ExecutionError.new('Unauthorized', extensions: { code: 'UNAUTHORIZED' })
      end

      def raise_internal_server_error!(exception)
        if Rails.env.development?
          Rails.logger.error(exception.message)
          Rails.logger.error(exception.backtrace&.join("\n"))
        end

        raise GraphQL::ExecutionError.new('Internal Server Error', extensions: { code: 'INTERNAL_SERVER_ERROR' })
      end

      private

      def raise_validation_error!(details)
        raise GraphQL::ExecutionError.new('Validation Error',
                                          extensions: { code: 'VALIDATION_ERROR', details: details })
      end
    end
  end
end

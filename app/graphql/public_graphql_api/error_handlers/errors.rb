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

      def raise_unauthenticated_error!
        raise GraphQL::ExecutionError.new(
          'Unauthenticated',
          extensions: {
            code: 'UNAUTHENTICATED'
          }
        )
      end

      private

      def raise_validation_error!(details)
        raise GraphQL::ExecutionError.new(
          'Validation Error',
          extensions: {
            code:    'VALIDATION_ERROR',
            details: details
          }
        )
      end
    end
  end
end

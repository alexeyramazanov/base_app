# frozen_string_literal: true

module PublicGraphqlApi
  module ErrorHandlers
    module Rescue
      extend ActiveSupport::Concern

      included do
        rescue_from ActiveRecord::RecordNotFound do |_err, _obj, _args, _ctx, _field|
          raise GraphQL::ExecutionError.new('Not Found', extensions: { code: 'NOT_FOUND' })
        end

        rescue_from Pundit::NotAuthorizedError do |_err, _obj, _args, _ctx, _field|
          raise GraphQL::ExecutionError.new('Unauthorized', extensions: { code: 'UNAUTHORIZED' })
        end

        rescue_from Exception do |err, _obj, _args, _ctx, _field|
          if Rails.env.development?
            Rails.logger.error(err.message)
            Rails.logger.error(err.backtrace.join("\n"))
          end

          raise GraphQL::ExecutionError.new('Internal Server Error', extensions: { code: 'INTERNAL_SERVER_ERROR' })
        end

        # called when default GraphQL object authorization fails
        def self.unauthorized_object(_error)
          raise GraphQL::ExecutionError.new('Unauthorized', extensions: { code: 'UNAUTHORIZED' })
        end

        # called when default GraphQL field authorization fails
        def self.unauthorized_field(_error)
          # do not raise exception, just return nil for this field
          nil
        end
      end
    end
  end
end

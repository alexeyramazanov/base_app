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

        rescue_from Exception do |_err, _obj, _args, _ctx, _field|
          raise GraphQL::ExecutionError.new('Internal Server Error', extensions: { code: 'INTERNAL_SERVER_ERROR' })
        end
      end
    end
  end
end

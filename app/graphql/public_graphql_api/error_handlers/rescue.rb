# frozen_string_literal: true

module PublicGraphqlApi
  module ErrorHandlers
    module Rescue
      extend ActiveSupport::Concern

      included do
        extend ErrorHandlers::Errors

        rescue_from ActiveRecord::RecordNotFound do |_err, _obj, _args, _ctx, _field|
          raise_record_not_found_error!
        end

        rescue_from Pundit::NotAuthorizedError do |_err, _obj, _args, _ctx, _field|
          raise_unauthorized_error!
        end

        rescue_from Exception do |err, _obj, _args, _ctx, _field|
          raise_internal_server_error!(err)
        end

        # called when default GraphQL object authorization fails
        def self.unauthorized_object(_error)
          raise_unauthorized_error!
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

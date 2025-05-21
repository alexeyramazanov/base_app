# frozen_string_literal: true

module PublicApi
  module ExceptionHandlers
    extend ActiveSupport::Concern

    included do
      rescue_from Grape::Exceptions::ValidationErrors do |e|
        error_unprocessable_entity!(*e.full_messages)
      end

      rescue_from ActiveRecord::RecordNotFound do
        error_not_found!
      end

      # TODO: log errors
      rescue_from :all do
        internal_server_error!
      end
    end
  end
end

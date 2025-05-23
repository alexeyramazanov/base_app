# frozen_string_literal: true

module PublicApi
  module ExceptionHandlers
    extend ActiveSupport::Concern

    included do
      rescue_from Grape::Exceptions::ValidationErrors do |e|
        log_exception(e)
        error_unprocessable_entity!(*e.full_messages)
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        log_exception(e)
        error_not_found!
      end

      rescue_from Pagy::VariableError do |e|
        error_unprocessable_entity!(e.message)
      end

      rescue_from :all do |e|
        log_exception(e)
        internal_server_error!
      end
    end
  end
end

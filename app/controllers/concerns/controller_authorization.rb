# frozen_string_literal: true

module ControllerAuthorization
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'

    redirect_to dashboard_url
  end
end

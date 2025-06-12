# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization
  include ControllerAuthentication

  allow_browser versions: :modern

  after_action :verify_pundit_authorization

  private

  def verify_pundit_authorization
    if action_name == 'index'
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  def pundit_user
    Current.user
  end
end

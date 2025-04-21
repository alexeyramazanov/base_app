# frozen_string_literal: true

module Admin
  class BaseController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include ControllerAdminAuthentication

    # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
    allow_browser versions: :modern

    layout 'admin'
  end
end

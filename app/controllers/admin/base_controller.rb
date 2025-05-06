# frozen_string_literal: true

module Admin
  class BaseController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include ControllerAdminAuthentication

    allow_browser versions: :modern

    layout 'admin'
  end
end

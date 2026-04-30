# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Method
  include ControllerAuthentication
  include ControllerAuthorization

  allow_browser versions: :modern
end

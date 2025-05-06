# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ControllerAuthentication

  allow_browser versions: :modern
end

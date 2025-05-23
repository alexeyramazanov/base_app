# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :require_authentication
  skip_before_action :redirect_if_admin

  before_action :skip_authorization

  def too_many_requests
  end

  def swagger
    render layout: 'swagger'
  end
end

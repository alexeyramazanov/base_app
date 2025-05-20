# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :require_authentication

  before_action :skip_authorization

  def too_many_requests
  end

  def swagger
    render layout: 'swagger'
  end
end

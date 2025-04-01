# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :require_authentication

  def too_many_requests
  end
end

# frozen_string_literal: true

class HomeController < ApplicationController
  allow_only_unauthenticated_access

  before_action :skip_authorization

  layout 'public'

  def show
  end

  def about
  end
end

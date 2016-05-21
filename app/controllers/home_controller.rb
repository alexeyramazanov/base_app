class HomeController < ApplicationController
  skip_before_action :require_login
  before_action :redirect_if_authenticated

  def show
  end
end

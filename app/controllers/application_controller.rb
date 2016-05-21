class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login

  protected

  def not_authenticated
    redirect_to login_url, alert: 'Please login first'
  end

  def redirect_if_authenticated
    redirect_to dashboard_url if current_user
  end
end

module Admin
  class BaseController < ApplicationController
    skip_before_action :redirect_if_admin
    before_action :redirect_if_not_admin

    protected

    def redirect_if_not_admin
      redirect_to dashboard_url unless current_user.admin?
    end
  end
end

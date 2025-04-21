# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def show
      @new_users = User.order(created_at: :desc).limit(5)
    end

    def request_user_stats
      Admin::UserStatsJob.perform_async(Current.admin_user.id)
      flash.now[:notice] = 'You will receive an email soon.'
    end
  end
end

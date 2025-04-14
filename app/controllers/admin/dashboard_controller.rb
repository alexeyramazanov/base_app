# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def show
    end

    def request_user_stats
      Admin::UserStatsJob.perform_async(Current.admin_user.id)
    end
  end
end

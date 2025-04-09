# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def show
    end

    # TODO: refresh frame with turbo
    def request_user_stats
      Admin::UserStatsJob.perform_async(Current.admin_user.id)

      redirect_to dashboard_path, notice: 'You will receive an email soon.'
    end
  end
end

# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @new_users = policy_scope(User).order(created_at: :desc).limit(5)
    end

    def request_user_stats
      authorize :user

      Admin::UserStatsJob.perform_async(Current.admin_user.id)
      flash.now[:notice] = 'You will receive an email soon.'
    end
  end
end

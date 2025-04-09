# frozen_string_literal: true

module Admin
  class UserStatsJob
    include Sidekiq::Job

    def perform(admin_user_id)
      count = User.count

      AdminMailer.with(send_to_id: admin_user_id, users_count: count).user_stats.deliver_later
    end
  end
end

# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def user_stats
    @admin = AdminUser.find(params[:send_to_id])
    @users_count = params[:users_count]

    mail to: @admin.email, subject: 'User statistics'
  end
end

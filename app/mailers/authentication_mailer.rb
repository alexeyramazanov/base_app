# frozen_string_literal: true

class AuthenticationMailer < ApplicationMailer
  def activation_link
    @user = User.find(params[:user_id])

    mail to: @user.email, subject: 'Activate your account'
  end

  def reset_password
    @user = User.find(params[:user_id])

    mail to: @user.email, subject: 'Reset password instructions'
  end
end

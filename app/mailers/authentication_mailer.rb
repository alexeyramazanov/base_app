# frozen_string_literal: true

class AuthenticationMailer < ApplicationMailer
  def activation_link
    @user = params[:user]

    mail to: @user.email, subject: 'Activate your account'
  end

  def reset_password
    @user = params[:user]

    mail to: @user.email, subject: 'Reset password instructions'
  end
end

class AuthenticationMailer < ActionMailer::Base
  def activation_needed_email(user)
    @user = user
    mail(to: @user.email, subject: 'Confirmation instructions')
  end

  def activation_success_email(user)
    @user = user
    mail(to: @user.email, subject: 'Account successfully activated')
  end

  def reset_password_email(user)
    @user = user
    mail(to: @user.email, subject: 'Reset password instructions')
  end

  def reset_password_success_email(user)
    @user = user
    mail(to: @user.email, subject: 'New password for your account')
  end
end

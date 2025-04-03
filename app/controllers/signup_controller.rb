# frozen_string_literal: true

class SignupController < ApplicationController
  allow_only_unauthenticated_access

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to too_many_requests_url }

  layout 'public'

  def new
    @user = User.new
  end

  def create
    @user = User.new(create_user_params)

    if @user.save
      @user.send_activation_link

      redirect_to success_signup_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def success
  end

  def activate
    user = User.activate_account(params[:token])

    redirect_to sign_in_url, notice: 'Account activated. You can sign in now.' if user
  end

  def request_activation_link
    return if request.get?

    user = User.find_by(email: params[:email])
    user&.send_activation_link

    redirect_to success_signup_url
  end

  private

  def create_user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

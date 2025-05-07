# frozen_string_literal: true

class PasswordResetController < ApplicationController
  allow_only_unauthenticated_access

  before_action :skip_authorization
  before_action :set_user_by_token, only: %i[edit update]

  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { redirect_to too_many_requests_url }

  layout 'public'

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    user&.send_password_reset_link

    redirect_to success_password_reset_url
  end

  def success
  end

  def edit
  end

  def update
    if @user.update_password(new_password_params)
      redirect_to sign_in_url, notice: 'Password has been reset.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_reset_password_token(params[:token]) # rubocop:disable Rails/DynamicFindBy
    redirect_to password_reset_url, alert: 'Password reset link is invalid or has expired.' unless @user
  end

  def new_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

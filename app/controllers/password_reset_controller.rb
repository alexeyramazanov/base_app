class PasswordResetController < ApplicationController
  skip_before_filter :require_login
  before_filter :load_user, only: [:edit, :update]

  def new
  end

  def create
    @user = User.where(email: params[:email]).first

    @user.deliver_reset_password_instructions! if @user
  end

  def edit
  end

  def update
    @user.update_password = true
    if @user.change_password!(params[:user][:password])
      redirect_to login_path, notice: 'Password was successfully updated.'
    else
      render :edit
    end
  end

  protected

  def load_user
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    redirect_to new_reset_password_url, alert: 'Incorrect link.' unless @user
  end
end

class ProfileController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    @user.update_password = true
    if @user.update(user_params)
      redirect_to edit_profile_url, notice: 'Password was successfully updated.'
    else
      render :edit
    end
  end

  protected

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

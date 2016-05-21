class RegistrationController < ApplicationController
  skip_before_action :require_login
  before_action :redirect_if_authenticated

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    unless @user.save
      render 'new'
    end
  end

  def activate
    @user = User.load_from_activation_token(params[:token])

    if @user
      @user.activate!
      auto_login(@user)
      redirect_to root_url
    end
  end

  protected

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

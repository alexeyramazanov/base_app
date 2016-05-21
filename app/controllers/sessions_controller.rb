class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :redirect_if_authenticated, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    if (@user = login(params[:email], params[:password]))
      redirect_back_or_to(:root, notice: 'Login successful')
    else
      flash.now[:alert] = 'Login failed'
      render 'new'
    end
  end

  def destroy
    logout
    redirect_to :root
  end
end

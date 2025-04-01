# frozen_string_literal: true

class SignInController < ApplicationController
  allow_only_unauthenticated_access only: %i[new create]

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to too_many_requests_url }

  def new
  end

  def create
    status, user = User.authenticate(user_params)

    case status
    when :success
      start_new_session_for(user)

      redirect_to after_authentication_url
    when :activation_required
      flash.now[:alert] = 'You need to activate your account first.'
      render 'new', status: :unprocessable_entity
    else
      flash.now[:alert] = 'Invalid email or password.'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session

    redirect_to root_url
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end

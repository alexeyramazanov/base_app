# frozen_string_literal: true

class SignInController < ApplicationController
  allow_only_unauthenticated_access only: %i[new create]

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to too_many_requests_url }

  layout 'public'

  def new
  end

  def create
    status, user = User.authenticate(user_params)

    if status == :success
      start_new_session_for(user)

      redirect_to after_authentication_url
    else
      flash.now[:alert] = helpers.authentication_status_error_message(status)
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

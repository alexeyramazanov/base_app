# frozen_string_literal: true

class ProfileController < ApplicationController
  def show
  end

  def update
    user = Current.user

    unless user.authenticate_password(params[:current_password])
      flash.now[:alert] = 'Incorrect current password'
      render 'show', status: :unprocessable_entity and return
    end

    if user.update_password(password_update_params)
      redirect_to profile_url, notice: 'Password successfully updated'
    else
      flash.now[:alert] = user.errors.full_messages.join('<br>').html_safe
      render 'show', status: :unprocessable_entity
    end
  end

  private

  def password_update_params
    params.permit(:password, :password_confirmation)
  end
end

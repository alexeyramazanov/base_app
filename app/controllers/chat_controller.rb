# frozen_string_literal: true

class ChatController < ApplicationController
  def show
    authorize ChatMessage

    @room = ChatMessage::ROOMS.include?(params[:room]) ? params[:room] : nil
    redirect_to chat_path(ChatMessage::ROOMS.first) and return unless @room

    @last_messages = ChatMessage.preload(:user).where(room: @room).order(:created_at).last(30)
  end
end

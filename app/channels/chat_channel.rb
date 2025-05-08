# frozen_string_literal: true

class ChatChannel < ApplicationCable::Channel
  state_attr_accessor :channel, :room

  def subscribed
    self.channel = ChatMessage::ROOMS.include?(params[:room]) ? "chat:#{params[:room]}" : nil
    reject unless channel

    self.room = params[:room]

    stream_from channel
  end

  def speak(data)
    message = data.fetch('message')
    return if message.blank?

    chat_message = ChatMessage.create!(room: room, user: current_user, message: message)

    msg = {
      action: 'newMessage',
      html:   html('chat/message', user: current_user, message: chat_message)
    }

    # can't use `broadcast_to` because it requires a model, but we have hand-crafted channels
    ActionCable.server.broadcast(channel, msg)
  end
end

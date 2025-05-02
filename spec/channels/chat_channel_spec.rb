# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatChannel do
  let(:user) { create(:user) }
  let(:room) { 'general' }

  before do
    stub_connection(current_user: user)
    subscribe(room: room)
  end

  describe '#subscribed' do
    it 'successfully subscribes to the channel and streams from it' do
      subscription

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("chat:#{room}")
    end

    it 'persists channel state objects' do
      subscription

      expect(subscription.channel).to eq("chat:#{room}")
      expect(subscription.room).to eq(room)
    end

    context 'with invalid room' do
      let(:room) { 'invalid_room' }

      it 'rejects the subscription' do
        subscription

        expect(subscription).to be_rejected
      end
    end
  end

  describe '#speak' do
    let(:message_text) { 'Hello, world!' }

    it 'creates a chat message with correct attributes' do
      expect { perform :speak, message: message_text }.to change(ChatMessage, :count).by(1)

      message = ChatMessage.last
      expect(message.room).to eq(room)
      expect(message.user).to eq(user)
      expect(message.message).to eq(message_text)
    end

    it 'broadcasts the message to the channel' do
      expected_hash = a_hash_including(
        action: 'newMessage',
        html:   including(message_text)
      )

      expect { perform :speak, message: message_text }.to have_broadcasted_to("chat:#{room}").with(expected_hash)
    end

    context 'with blank message' do
      let(:message_text) { '' }

      it 'does not create a new chat message' do
        expect { perform :speak, message: message_text }.not_to change(ChatMessage, :count)
      end

      it 'does not broadcast to the channel' do
        expect { perform :speak, message: message_text }.not_to have_broadcasted_to("chat:#{room}")
      end
    end
  end
end

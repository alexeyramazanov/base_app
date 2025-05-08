# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Channel do
  describe '#html' do
    subject(:channel) { described_class.new(connection, {}) }

    let(:user) { create(:user) }
    let(:message) { create(:chat_message, user: user, message: 'Hello World') }
    let(:partial) { 'chat/message' }
    let(:locals) { { user: user, message: message } }

    before do
      stub_connection
    end

    it 'renders the partial with the provided locals' do
      html = channel.send(:html, partial, **locals)

      expect(html).to include(user.email)
      expect(html).to include(message.message)
    end
  end
end

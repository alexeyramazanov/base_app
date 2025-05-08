# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe ChatController do
  let(:user_session) { create(:user_session) }

  before do
    cookies.signed[:session_id] = user_session.id
  end

  describe 'GET #show' do
    before do
      create_list(:chat_message, 3, room: 'general')
    end

    it 'responds with success' do
      get :show, params: { room: 'general' }

      expect(response).to be_successful
    end

    context 'when chat room is not specified' do
      it 'redirects to default chat room' do
        get :show

        expect(response).to redirect_to(chat_url(ChatMessage::ROOMS.first))
      end
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :show, params: { room: 'general' } }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :show, params: { room: 'general' } }
    end
  end
end

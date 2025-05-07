# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe Admin::UsersController do
  let(:admin_user) { create(:admin_user) }
  let(:admin_session) { create(:admin_session, admin_user:) }

  before do
    cookies.signed[:admin_session_id] = admin_session.id
  end

  describe 'GET #index' do
    it 'responds with success' do
      get :index

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :index }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { get :index }
      let(:redirect_url) { admin_sign_in_url }
    end
  end

  describe '#request_user_stats' do
    before do
      allow(Admin::UserStatsJob).to receive(:perform_async)
    end

    it 'enqueues a job to generate user stats' do
      post :request_user_stats, format: :turbo_stream

      expect(Admin::UserStatsJob).to have_received(:perform_async).with(admin_user.id)
    end

    it 'sets a flash notice' do
      post :request_user_stats, format: :turbo_stream

      expect(flash.now[:notice]).to eq('You will receive an email soon.')
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { post :request_user_stats, format: :turbo_stream }
    end

    it_behaves_like 'page does not allow unauthenticated access' do
      let(:action) { post :request_user_stats, format: :turbo_stream }
      let(:redirect_url) { admin_sign_in_url }
    end
  end
end

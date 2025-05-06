# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ControllerAdminAuthentication do
  let(:user_session) { create(:user_session) }
  let(:admin_session) { create(:admin_session) }

  controller(ActionController::Base) do
    include ControllerAdminAuthentication # rubocop:disable RSpec/DescribedClass

    allow_only_unauthenticated_access only: %i[info]

    def index
      render plain: 'index'
    end

    def info
      render plain: 'info'
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'info' => 'anonymous#info'
    end
  end

  describe 'authentication flow' do
    context 'when admin is not authenticated' do
      it 'redirects to admin sign in page' do
        get :index

        expect(response).to redirect_to(admin_sign_in_url)
      end

      it 'stores the return URL in the session' do
        get :index

        expect(session[:return_to_after_authenticating]).to eq('http://test.host/index')
      end
    end

    context 'when admin is authenticated' do
      before do
        cookies.signed[:admin_session_id] = admin_session.id
      end

      it 'allows access to the page' do
        get :index

        expect(response).to be_successful
      end
    end

    context 'when user is authenticated' do
      before do
        cookies.signed[:session_id] = user_session.id
      end

      it 'redirects to user dashboard' do
        get :index

        expect(response).to redirect_to(dashboard_url)
      end
    end
  end

  describe '.allow_only_unauthenticated_access' do
    context 'when admin is not authenticated' do
      it 'allows access to the page' do
        get :info

        expect(response).to be_successful
      end
    end

    context 'when admin is authenticated' do
      before do
        cookies.signed[:admin_session_id] = admin_session.id
      end

      it 'redirects to admin dashboard' do
        get :info

        expect(response).to redirect_to(admin_dashboard_url)
      end
    end

    context 'when user is authenticated' do
      before do
        cookies.signed[:session_id] = user_session.id
      end

      it 'redirects to dashboard' do
        get :info

        expect(response).to redirect_to(dashboard_url)
      end
    end
  end

  describe '#after_authentication_url' do
    context 'when return_to_after_authenticating is set' do
      before do
        session[:return_to_after_authenticating] = '/custom_path'
      end

      it 'returns the stored URL and clears it from session' do
        url = controller.send(:after_authentication_url)

        expect(url).to eq('/custom_path')
        expect(session[:return_to_after_authenticating]).to be_nil
      end
    end

    context 'when return_to_after_authenticating is not set' do
      it 'returns the admin info URL' do
        url = controller.send(:after_authentication_url)

        expect(url).to eq(admin_dashboard_url)
      end
    end
  end

  describe '#resume_session' do
    before do
      allow(Current).to receive(:session=)
    end

    context 'when admin is not authenticated' do
      it 'does not assign a session' do
        get :index

        expect(Current).to have_received(:session=).with(nil)
      end
    end

    context 'when admin is authenticated' do
      before do
        cookies.signed[:admin_session_id] = admin_session.id
      end

      it 'assigns the admin session' do
        get :index

        expect(Current).to have_received(:session=).with(admin_session)
      end
    end

    context 'when user is authenticated' do
      before do
        cookies.signed[:session_id] = user_session.id
      end

      it 'does not assign a session' do
        get :index

        expect(Current).to have_received(:session=).with(nil)
      end
    end
  end

  describe '#start_new_session_for' do
    let(:admin_user) { create(:admin_user) }

    before do
      allow(controller).to receive(:cookies).and_return(cookies)
    end

    it 'creates a new session for the admin' do
      expect { controller.send(:start_new_session_for, admin_user) }.to change(AdminSession, :count).by(1)

      session = AdminSession.last
      expect(session.admin_user).to eq(admin_user)
      expect(session.user_agent).to eq('Rails Testing')
      expect(session.ip_address).to eq('0.0.0.0')
    end

    it 'sets the Current.session' do
      allow(Current).to receive(:session=)

      controller.send(:start_new_session_for, admin_user)

      expect(Current).to have_received(:session=).with(instance_of(AdminSession))
    end

    it 'sets the admin session cookie' do
      controller.send(:start_new_session_for, admin_user)

      expect(cookies.signed[:admin_session_id]).to eq(admin_user.sessions.last.id)

      cookie_to_set = cookies.instance_variable_get(:@set_cookies)['admin_session_id']
      expect(cookie_to_set[:expires]).to be_within(5.seconds).of(2.weeks.from_now)
      expect(cookie_to_set[:httponly]).to be(true)
      expect(cookie_to_set[:same_site]).to eq(:lax)
      expect(cookie_to_set[:secure]).to eq(Rails.configuration.force_ssl)
      expect(cookie_to_set[:path]).to eq('/')
    end
  end

  describe '#terminate_session' do
    before do
      allow(Current).to receive(:session).and_return(admin_session)
      allow(controller).to receive(:cookies).and_return(cookies)
    end

    it 'destroys the current session' do
      controller.send(:terminate_session)

      expect(admin_session).to be_destroyed
    end

    it 'deletes the session cookie' do
      cookies.signed[:admin_session_id] = admin_session.id

      controller.send(:terminate_session)

      expect(cookies.signed[:admin_session_id]).to be_nil
    end
  end
end

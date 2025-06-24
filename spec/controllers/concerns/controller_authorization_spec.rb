# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ControllerAuthorization do
  let!(:user_session) { create(:user_session) }

  controller(ActionController::Base) do
    include ControllerAuthorization # rubocop:disable RSpec/DescribedClass

    def index
      render plain: 'index'
    end

    def info
      render plain: 'info'
    end

    def user
      Current.session = UserSession.last

      authorize Current.user, :show?

      render plain: pundit_user.email
    end

    def not_authorized
      Current.session = UserSession.last

      authorize Current.user, :destroy?

      render plain: 'not_authorized'
    end

    def dashboard
      render plain: 'dashboard'
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'info' => 'anonymous#info'
      get 'user' => 'anonymous#user'
      get 'not_authorized' => 'anonymous#not_authorized'
      get 'dashboard' => 'anonymous#dashboard'
    end
  end

  describe 'pundit controller authorization check' do
    context 'when calling index action' do
      it 'verifies policy scope was used' do
        expect { get :index }.to raise_error(Pundit::PolicyScopingNotPerformedError)
      end
    end

    context 'when calling regular action' do
      it 'verifies action was authorized' do
        expect { get :info }.to raise_error(Pundit::AuthorizationNotPerformedError)
      end
    end
  end

  describe '#pundit_user' do
    it 'returns the current user' do
      get :user

      expect(response.body).to eq(user_session.user.email)
    end
  end

  describe 'accessing not authorized action' do
    it 'redirects to the dashboard with alert notification' do
      get :not_authorized

      expect(response).to redirect_to(dashboard_url)
      expect(flash[:alert]).to eq('You are not authorized to perform this action.')
    end
  end
end

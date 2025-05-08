# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe HomeController do
  describe 'GET #show' do
    it 'responds with success' do
      get :show

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :show }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :show }
    end
  end

  describe 'GET #about' do
    it 'responds with success' do
      get :about

      expect(response).to be_successful
    end

    it_behaves_like 'page does not allow user access' do
      let(:action) { get :show }
    end

    it_behaves_like 'page does not allow admin access' do
      let(:action) { get :show }
    end
  end
end

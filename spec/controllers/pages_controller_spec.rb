# frozen_string_literal: true

require 'rails_helper'
require 'shared/controller_access'

RSpec.describe PagesController do
  describe 'GET #too_many_requests' do
    it 'responds with success' do
      get :too_many_requests

      expect(response).to be_successful
    end
  end

  describe 'GET #swagger' do
    it 'responds with success' do
      get :swagger

      expect(response).to be_successful
    end
  end
end

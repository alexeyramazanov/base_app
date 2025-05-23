# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ApiTokensController do
  let(:password) { '123123' }
  let(:admin_user) { create(:admin_user, password: password, password_confirmation: password) }

  describe 'api tokens list' do
    before do
      create_list(:api_token, 3)
    end

    it 'is displayed' do
      sign_in(admin_user, password, admin: true)

      visit admin_api_tokens_path

      expect(page).to have_text('API Tokens')

      within('#api_tokens') do
        expect(page).to have_css('tbody tr', count: 3)
      end
    end
  end

  describe 'create api token' do
    let!(:user) { create(:user) }

    it 'creates api token and displays it' do
      sign_in(admin_user, password, admin: true)

      visit admin_api_tokens_path

      select user.email, from: 'User'
      click_button 'Create'

      within('#modal') do
        expect(page).to have_text('This is an API Token generated for user')
        expect(page).to have_text(/^[A-Za-z0-9]{32}$/)

        click_button 'I saved the token'
      end

      within('#api_tokens') do
        expect(page).to have_css('tbody tr', count: 1)
        expect(page).to have_text(user.email)
      end
    end
  end
end

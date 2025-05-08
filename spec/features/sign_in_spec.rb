# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignInController do
  describe 'sign in functionality' do
    let(:password) { '123123' }
    let(:user) { create(:user, email: 'user@email.com', password: password, password_confirmation: password) }

    it 'allows user to sign in' do
      visit sign_in_path

      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_button 'Sign in'

      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_text('Dashboard')
      expect(page).to have_text('Hello World!')
    end

    context 'when credentials are invalid' do
      it 'displays errors' do
        visit sign_in_path

        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'some_password'
        click_button 'Sign in'

        expect(page).to have_current_path(sign_in_path)
        expect(page).to have_text('Invalid email or password')
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  describe 'root page' do
    it 'renders correctly' do
      visit root_path

      expect(page).to have_link('About Us', href: %r{/about})
      expect(page).to have_link('Sign up', href: %r{/signup})
      expect(page).to have_link('Sign in', href: %r{/sign_in})

      expect(page).to have_text('Base App Rails Application')
    end
  end

  describe 'about page' do
    it 'renders correctly' do
      visit about_path

      expect(page).to have_selector('img[src="https://dummyimage.com/1000x600"]')
    end
  end
end

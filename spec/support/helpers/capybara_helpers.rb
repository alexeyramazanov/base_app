# frozen_string_literal: true

module CapybaraHelpers
  def sign_in(user, password)
    visit sign_in_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button 'Sign in'

    expect(page).to have_text('Dashboard')
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature
end

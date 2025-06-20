# frozen_string_literal: true

module CapybaraHelpers
  include ActionView::RecordIdentifier

  DOWNLOAD_PATH = Rails.root.join('tmp/capybara/downloads').to_s.freeze

  def sign_in(user, password, admin: false)
    visit(admin ? admin_sign_in_path : sign_in_path)

    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button 'Sign in'

    expect(page).to have_text('Dashboard')
  end

  def css_id(*args)
    "##{dom_id(*args)}"
  end

  def downloads
    Dir[File.join(DOWNLOAD_PATH, '*')]
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature

  config.before(:each, type: :feature) do
    clear_downloads
  end

  config.after(:each, type: :feature) do
    clear_downloads
  end
end

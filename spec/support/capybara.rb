# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.register_driver :selenium_chrome_headless do |app|
  profile = Selenium::WebDriver::Chrome::Profile.new
  profile['profile.password_manager_leak_detection'] = false

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--force-device-scale-factor=1')
  options.logging_prefs = { 'browser' => 'ALL' }
  options.profile = profile

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :selenium_chrome do |app|
  profile = Selenium::WebDriver::Chrome::Profile.new
  profile['profile.password_manager_leak_detection'] = false

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--window-size=1600,900')
  options.add_argument('--auto-open-devtools-for-tabs')
  options.logging_prefs = { 'browser' => 'ALL' }
  options.profile = profile

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :selenium_chrome_headless # use :selenium_chrome for debugging

RSpec.configure do |config|
  config.after(:each, type: :feature) do |example|
    next unless example.exception

    errors = page.driver.browser.logs.get(:browser)

    if errors.present?
      message = errors.map(&:message).join("\n")
      puts "\n\n#{message}\n"
    end
  end
end

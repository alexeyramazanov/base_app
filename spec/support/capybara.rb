# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--force-device-scale-factor=1')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :selenium_chrome_headless # use :selenium_chrome for debugging

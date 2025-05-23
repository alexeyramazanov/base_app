# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :selenium_chrome_headless # use :selenium_chrome for debugging

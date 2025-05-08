# frozen_string_literal: true

FactoryBot.define do
  factory :admin_session do
    admin_user

    ip_address { '142.250.203.142' }
    user_agent { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36' } # rubocop:disable Layout/LineLength
  end
end

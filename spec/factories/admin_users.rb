# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    email { 'admin@email.com' }
    password { '123123' }
    password_confirmation { '123123' }

    # cleanup attributes to match the case when the admin user is fetched from DB
    after(:create) do |admin_user|
      # do not use direct assignment here as it will trigger `password_digest` update
      admin_user.instance_variable_set(:@password, nil)
      admin_user.instance_variable_set(:@password_confirmation, nil)
    end
  end
end

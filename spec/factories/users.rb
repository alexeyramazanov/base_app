# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'user@email.com' }
    password { '123123' }
    password_confirmation { '123123' }
    activation_state { 'active' }

    # cleanup attributes to match the case when the user is fetched from DB
    after(:create) do |user|
      # do not use direct assignment here as it will trigger `password_digest` update
      user.instance_variable_set(:@password, nil)
      user.instance_variable_set(:@password_confirmation, nil)
    end
  end
end

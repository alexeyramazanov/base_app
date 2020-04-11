FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@gmail.com" }
    password { '123123' }
    #password_confirmation { password }
    role { 'user' }

    trait :admin do
      role { 'admin' }
    end

    factory :admin, traits: [:admin]
  end
end

# frozen_string_literal: true

if Rails.env.development?
  AdminUser.create!(email: 'admin@baseapp.com', password: '123123', password_confirmation: '123123')
end

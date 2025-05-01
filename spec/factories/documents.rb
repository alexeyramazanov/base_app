# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    user

    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg')) }
  end
end

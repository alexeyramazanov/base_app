# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  else
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
      aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
      region:                ENV.fetch('AWS_REGION'),
      endpoint:              ENV.fetch('AWS_ENDPOINT', nil),
      path_style:            ENV.fetch('AWS_PATH_STYLE') == 'true'
    }
    config.fog_directory = ENV.fetch('AWS_BUCKET')
    config.fog_public = false
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
    config.storage = :fog
  end
end

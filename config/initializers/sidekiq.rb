# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'] }
end

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  # use `&` (do not use `&&`) so that it doesn't short circuit (protect against timing attacks)
  ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_LOGIN'])
  ) &
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'])
    )
end

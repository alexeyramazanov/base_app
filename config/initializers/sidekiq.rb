# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('SIDEKIQ_REDIS_URL', nil) }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('SIDEKIQ_REDIS_URL', nil) }
end

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  # use `&` (do not use `&&`) so that it doesn't short circuit (protect against timing attacks)
  ActiveSupport::SecurityUtils.secure_compare(
    Digest::SHA256.hexdigest(username), Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_LOGIN', nil))
  ) &
    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(password), Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_PASSWORD', nil))
    )
end

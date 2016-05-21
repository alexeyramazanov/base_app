# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

# The environment variable WEB_CONCURRENCY may be set to a default value based
# on dyno size. To manually configure this value use heroku config:set
# WEB_CONCURRENCY.
#
# Increasing the number of workers will increase the amount of resting memory
# your dynos use. Increasing the number of threads will increase the amount of
# potential bloat added to your dynos when they are responding to heavy
# requests.
#
# Starting with a low number of workers and threads provides adequate
# performance for most applications, even under load, while maintaining a low
# risk of overusing memory.

workers Integer(ENV.fetch('WEB_CONCURRENCY', 2))
threads_count = Integer(ENV.fetch('MAX_THREADS', 2))
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port ENV.fetch('PORT', 3000)
environment ENV.fetch('RACK_ENV', 'development')

before_fork do
  # this, however does not kill connection reaper (ActiveRecord::ConnectionAdapters::ConnectionPool::Reaper),
  # so it continues to run in master process and causes WARNINGs in puma logs
  # but seems this is not critical because we close all connections in master process
  ActiveRecord::Base.connection_pool.disconnect!
end

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

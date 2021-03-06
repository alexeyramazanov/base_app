source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.0'
gem 'pg', '>= 0.18', '< 2.0'

gem 'hamlit-rails'

gem 'webpacker'
gem 'react-rails'

# NOTE: master includes fixes for Rails 6, waiting for 0.15+
gem 'sorcery', github: 'Sorcery/sorcery'
gem 'enumerize'

gem 'sidekiq'
gem 'sidekiq-cron'

gem 'puma'

gem 'bootsnap', require: false

group :production do
  gem 'rack-timeout'
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
  gem 'rack-mini-profiler'
  gem 'bullet'
end

group :development, :test do
  gem 'awesome_print'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'bundler-audit', require: false
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
end

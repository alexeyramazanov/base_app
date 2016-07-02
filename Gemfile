source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '5.0.0'
gem 'pg'

gem 'haml-rails'
gem 'sassc-rails'
gem 'sprockets-es6'

gem 'jquery-rails'
gem 'bootstrap-sass'

gem 'autoprefixer-rails'
gem 'uglifier'

gem 'sorcery'

gem 'sidekiq'
gem 'sinatra', github: 'sinatra/sinatra', require: nil # sidekiq UI

gem 'nokogiri', '~> 1.6.8.rc3' # temporary

gem 'puma'

group :production do
  gem 'rack-timeout'
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'rack-mini-profiler'
  gem 'bullet'
end

group :development, :test do
  gem 'awesome_print'
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'bundler-audit', require: false
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
end

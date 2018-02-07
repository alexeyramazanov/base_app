source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.4.3'

gem 'rails', '5.1.4'
gem 'pg', '~> 0.21'

gem 'haml-rails'
gem 'sassc-rails'
gem 'sprockets-es6'

gem 'autoprefixer-rails'
gem 'uglifier'

gem 'sorcery'

gem 'sidekiq'

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

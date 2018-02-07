# Base App

## Purpose

Stop wasting time on creating basic rails app.

## What's inside

* postgres
* haml, sass, jquery, bootstrap
* sorcery authentication
* sidekiq background processing

## How To Use
1. `git clone --depth=1 --branch=master git@github.com:alexeyramazanov/base_app.git my_new_app`
1. `cd my_new_app`
1. `rm -rf .git`
1. `rake rename_app['BrandNewName']`
1. `rm lib/tasks/rename_app.rake`
1. `cp config/database.example.yml config/database.yml`
1. update `config/database.yml`
1. `cp .env.example .env.local`
1. update `.env.local`

Required `ENVs`:
* `SECRET_KEY_BASE` (you can get it by running `rake secret`)
* `DATABASE_URL` (for example `postgres://{user}:{password}@{hostname}:{port}/{database-name}`)

## Notes

* You can use foreman/forego. To see app log add the following code to the `config/environments/development.rb`:
```ruby
  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
```
* no support for IE8

## Known Issues
If you see `No such file or directory @ unlink_internal - .../pids/server.pid (Errno::ENOENT)`
that's not a problem, read [this](https://github.com/puma/puma/issues/915) for more info.

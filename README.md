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
2. `rm -rf my_new_app/.git`
2. `rake rename_app['BrandNewName']`
4. delete `lib/tasks/rename_app.rake`
3. update `config/database.yml`
4. set environment variables (check `.env.example` for a list of available variables)

## Notes

* You can use foreman/forego (to see app log add [rails_stdout_logging](https://github.com/heroku/rails_stdout_logging) gem to the `Gemfile`).
* no support for IE8

## Known Issues
If you see `No such file or directory @ unlink_internal - .../pids/server.pid (Errno::ENOENT)`
that's not a problem, read [this](https://github.com/puma/puma/issues/915) for more info.
# Base App

## Purpose

Stop wasting time on creating basic rails app.

## What's inside

* postgres
* haml, sass, jquery, bootstrap
* sorcery authentication
* sidekiq background processing

## How To Use
1. clone
2. `rake rename_app['BrandNewName']`
4. delete `lib/tasks/rename_app.rake`
3. update `config/database.yml`
4. set environment variables (check `.env.example` for a list of available variables)

## Notes

* You can use foreman/forego if you want.
* no support for IE8

## Known Issues
If you see `No such file or directory @ unlink_internal - .../pids/server.pid (Errno::ENOENT)`
that's not a problem, read [this](https://github.com/puma/puma/issues/915) for more info.

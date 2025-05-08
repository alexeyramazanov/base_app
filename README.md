# Base App

## Purpose

Stop wasting time on creating basic Ruby on Rails applications.

## What's inside

### Components

* PostgreSQL
* Redis
* Vite
* Tailwind CSS
* Font Awesome
* Hotwire (Turbo/Stimulus)
* AnyCable with Solid Cable and Turbo support
* Sidekiq (+ cron)
* Shrine (Amazon S3)
* Pundit

### Features

* Basic UI
* Simple authentication
* Admin panel
* Chat example (AnyCable + Hotwire) 
* File upload example (Direct S3 upload via Uppy)

## How To Use

1. `git clone --depth=1 --branch=main git@github.com:alexeyramazanov/base_app.git my_new_app`
2. `cd my_new_app`
3. `rm -rf .git`
4. `rake rename_app['BrandNewName']`
5. `rm lib/tasks/rename_app.rake`
6. update `config/database.yml`
7. update `db/seeds.rb`
8. update `.env.development.local`
9. update `.env.test.local`
10. `rm README.md`
11. `bundle`
12. `npm install`

## Docker

`docker build -t base_app .`

`docker compose up`

## Notes

You can use [foreman](https://github.com/ddollar/foreman)/[overmind](https://github.com/DarthSim/overmind) to run the application:

```shell
foreman start -f Procfile.dev -e .env.development.local
OVERMIND_ENV=.env.development.local overmind s -f Procfile.dev --no-port
```

Using Overmind allows you to use interactive processes (like `debugger`) simply by connecting to running `web` instance in second console:

```shell
overmind c web
```

## Known issues

#### AnyCable testing

If you run dev server and specs at the same time on the same machine — you'll probably notice that AnyCable/Action Cable broadcasted messages are shared between dev server and specs.

This happens because Pub/Sub channels in Redis are not scoped to individual logical databases and AnyCable does not support channel prefixing (like Action Cable does via `channel_prefix` option).

To avoid this, you need to have a second redis server and configure AnyCable to use it for test env.

#### Forking error

If you see

```
objc[70458]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
objc[70458]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```

when starting rails server just add `PGGSSENCMODE=disable` to your `.env` file. This is not related to Rails, see more info here — https://github.com/rails/rails/issues/38560#issuecomment-1881733872.


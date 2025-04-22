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

### Features

* Basic UI
* Simple authentication
* Admin panel
* Chat example (AnyCable + Hotwire) 
* File upload example (Direct S3 upload via Uppy)

## How To Use

TBD

## Docker

TBD

## Notes

You can use [foreman](https://github.com/ddollar/foreman)/[overmind](https://github.com/DarthSim/overmind) to run application:

```shell
foreman start -f Procfile.dev -e .env.development.local
OVERMIND_ENV=.env.development.local overmind s -f Procfile.dev --no-port
```

Using Overmind allows you to use interactive processes (like `debugger`) simply by connecting to running `web` instance in 2nd console:

```shell
overmind c web
```

## Known issues

If you see

```
objc[70458]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
objc[70458]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```

when starting rails server just add `PGGSSENCMODE=disable` to your `.env` file. This is not related to Rails, see more info here - https://github.com/rails/rails/issues/38560#issuecomment-1881733872.


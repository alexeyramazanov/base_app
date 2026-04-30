# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project Overview

**Base App** is an opinionated Ruby on Rails starter template designed to skip the boilerplate when spinning up a new Rails application. It bundles a set of common components and example features (auth, admin, chat, file uploads, REST + GraphQL APIs).

See `README.md` for user-facing setup/usage instructions, including the `rake rename_app['NewName']` task used to rebrand a fresh clone.

## Tech Stack

### Core

- **Ruby 4.0** (see `.ruby-version`)
- **Rails 8.1**
- **Node 24** - JS/CSS bundling
- **PostgreSQL 18** - primary database
- **Valkey 9 (redis)** - cache, Sidekiq, AnyCable pub/sub

### Components

- **Puma** + **Thruster** - web server
- **Vite** - JS/CSS bundling
- **Tailwind CSS 4** + **Font Awesome**
- **Hotwire** - Turbo + Stimulus
- **AnyCable** (with Solid Cable) - WebSockets / Action Cable replacement
- **Sidekiq** + **sidekiq-cron** - background jobs
- **Shrine** + **aws-sdk-s3** - file uploads (direct-to-S3 via Uppy)
- **Pundit** - authorization
- **AASM** - state machines
- **ViewComponent** - reusable view components
- **Pagy** - pagination
- **Grape** (+ grape-entity, grape-swagger) - REST API
- **GraphQL Ruby** - GraphQL API
- **Rspec** + **Factory bot** + **Capybara** - testing framework
- **CI/CD** - GitHub Actions
- **Deployment** - Docker + docker-compose

Actual versions of gems and libraries are specified in `Gemfile` and `package.json`.

## Repository Layout

```
app/
  api/           # Grape REST APIs (namespaced, e.g. public_rest_api/)
  channels/      # Action Cable / AnyCable channels
  components/    # ViewComponent classes
  controllers/   # Rails controllers, incl. admin/ namespace
  frontend/      # Vite entrypoint (JS/CSS assets, stimulus controllers)
  graphql/       # GraphQL schemas (namespaced, e.g. public_graphql_api/)
  models/        # AR models
  policies/      # Pundit policies
  sidekiq/       # Sidekiq jobs
  uploaders/     # Shrine uploaders
  mailers/       # Rails mailers
  views/         # Rails views
  helpers/       # Rails helpers
config/          # Rails config incl. AnyCable, Sidekiq, routes
db/              # migrations, schema.rb, seeds.rb
lib/tasks/       # rake tasks
spec/            # RSpec test suite (mirrors app/ structure)
bin/             # entry scripts
```

## Common Commands

### Setup

```
# bundle, db:prepare, etc.
bin/setup
```

Expect that environment is already set up.

### Running the app (dev)

```
bin/dev
# or via foreman
foreman start -f Procfile.dev -e .env.development.local
# or via overmind
OVERMIND_ENV=.env.development.local overmind s -f Procfile.dev --no-port
```

`Procfile.dev` spins up:
- `web` - Puma Rails server (port 3000)
- `vite` - Vite dev server (port 3036)
- `sidekiq` - Background workers
- `anycable-grpc` - AnyCable gRPC server (port 50051)
- `anycable-ws` - AnyCable WebSocket server (port 8080)

> **macOS fork issue**: if you see `objc_initializeAfterForkError`, add `PGGSSENCMODE=disable` to your `.env` files.

### Tests

```
rspec                                 # full suite
rspec spec/models/user_spec.rb        # single file
rspec spec/models/user_spec.rb:42     # single example
```

### Linting / Security

```
rubocop       # rubocop
rubocop -A    # rubocop auto-correct
brakeman      # security scan
```

## Environment

Environment variables are loaded via `dotenv`. Example files:
- `.env.example` / `.env.development.local`
- `.env.test.example` / `.env.test.local`
- `.env.compose.local` (docker-compose)

Never commit real secrets. When adding a new env var, update the relevant `.env.example` file.

## Conventions & Notes

- **No Devise**: authentication is hand-rolled using `bcrypt` with separate `user` / `admin_user` models and matching session models.
- **Namespaced APIs**: REST lives under `app/api/public_rest_api/`, GraphQL under `app/graphql/public_graphql_api/`. Follow the same namespacing pattern when adding new API surfaces.
- **Authorization**: use Pundit policies in `app/policies/`.
- **Background jobs**: place in `app/sidekiq/`, schedule recurring jobs via `sidekiq-cron`.
- **Views**: prefer `ViewComponent`s in `app/components/` over partials for reusable UI components.
- **Styling**: Tailwind 4 via `@tailwindcss/vite`; do not re-introduce `tailwind.config.js`-era patterns.
- **Frozen string literals**: required by RuboCop (except `Gemfile`, `Rakefile`, `config.ru`).
- **Business logic**: prefer service objects in `app/services/` over models.

## When Making Changes

- Run `rspec` and `rubocop` for created/changed files before declaring work done.
- Add/update specs alongside code changes - the spec tree mirrors `app/`.
- Keep the `Gemfile`'s inline comment-with-URL convention when adding new gems.
- Do not edit `db/schema.rb` by hand - generate migrations instead.

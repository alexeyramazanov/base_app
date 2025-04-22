# syntax=docker/dockerfile:1
# check=error=true

# base image used for all steps, ruby version should match version specified in .ruby-version
FROM docker.io/library/ruby:3.4.2-slim AS base

ARG ANYCABLE_VERSION=1.6.1
ARG ANYCABLE_URL="https://github.com/anycable/anycable/releases/download/v${ANYCABLE_VERSION}/anycable-go-linux-amd64"

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives && \
    curl -L -s -o anycable-go "${ANYCABLE_URL}" && \
    chmod +x anycable-go

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="true" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# build image used for building dependencies
FROM base AS build

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY package.json package-lock.json ./
RUN npm install

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

RUN rm -rf node_modules

# final image
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/app/bin/docker-entrypoint"]

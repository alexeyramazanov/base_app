# syntax=docker/dockerfile:1
# check=error=true

# base image used for all steps, ruby version should match version specified in .ruby-version
ARG RUBY_VERSION=4.0.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

ARG ANYCABLE_VERSION=1.6.12
ARG ANYCABLE_URL="https://github.com/anycable/anycable/releases/download/v${ANYCABLE_VERSION}/anycable-go-linux-amd64"

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips procps postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives && \
    curl -L -s -o anycable-go "${ANYCABLE_URL}" && \
    chmod +x anycable-go

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# build image used for building dependencies
FROM base AS build

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips libyaml-dev pkg-config libpq-dev nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY vendor/* ./vendor/
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

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /app /app

ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]

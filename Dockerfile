#============
# Build Stage
#============

# Base build image
FROM elixir:1.11.4-alpine as build

# Install hex & rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Prepare build dir
RUN mkdir /app
WORKDIR /app

# Set build ENV
ENV MIX_ENV=prod

# Copy the source folder into the image
COPY config ./config
COPY lib ./lib
COPY mix.exs ./
COPY mix.lock ./

# Install mix dependencies
RUN mix deps.get

# Build release
RUN mix release

#=================
# Deployment Stage
#=================

# Base image
FROM alpine:3.13

# Maintainer
LABEL maintainer="viastakhov@mail.ru"

# Environment vars
ENV REPLACE_OS_VARS=true
ENV ELIXIR_ERL_OPTS="+P 5000000"

# Install libs
RUN set -x \
	&& apk add --no-cache ncurses ncurses-libs

# Copy release files from the previous build stage
COPY --from=build /app/_build/prod/rel/ /usr/share

# Set working directory
WORKDIR /usr/share/gold_rush

# Set runtime user
RUN chown -R nobody: /usr/share/gold_rush
USER nobody

# Entrypoint
ENTRYPOINT ["/usr/share/gold_rush/bin/gold_rush"]
CMD ["start"]
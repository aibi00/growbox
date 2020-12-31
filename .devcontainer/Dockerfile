FROM elixir:1.11.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install --yes build-essential inotify-tools

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force hex nerves_bootstrap

WORKDIR /app

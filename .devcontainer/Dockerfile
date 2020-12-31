FROM elixir:1.11.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install --yes build-essential inotify-tools
RUN curl -LO https://github.com/fhunleth/fwup/releases/download/v1.8.3/fwup_1.8.3_amd64.deb
RUN apt-get install --yes ./fwup_1.8.3_amd64.deb

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force hex nerves_bootstrap

WORKDIR /app

# Installation

- Dependencies

```sh
sudo apt-get install -y autoconf curl git build-essential libncurses5-dev libssl-dev
```

- Clone repository

```sh
git clone https://github.com/aibi00/growbox
```

- asdf

```sh
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
. $HOME/.asdf/asdf.sh
asdf plugin-add elixir
asdf plugin-add erlang
```

- Install both Erlang and Elixir

```sh
cd growbox
asdf install
```

- Install nerves_bootstrap

```sh
mix archive.install hex nerves_bootstrap
```

- Install mix dependencies

```sh
export MIX_TARGET=rpi3
mix setup
```

- Flashing the Raspberry PI

```sh
MIX_ENV=prod MIX_TARGET=rpi3 mix burn
```

## Troubleshooting

- Failing to compile `:nerves_runtime`:

```
could not compile dependency :nerves_runtime, "mix compile" failed. You can recompile this dependency with "mix deps.compile nerves_runtime", update it with "mix deps.update nerves_runtime" or clean it with "mix deps.clean nerves_runtime"
```

Can be fix via `brew install fwup squashfs coreutils xz pkg-config`.
Also see https://github.com/nerves-project/nerves/blob/main/docs/Installation.md#macos

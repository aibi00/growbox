# Installation on Ubuntu

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
mix deps.get
```

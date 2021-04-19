defmodule Growbox.MixProject do
  use Mix.Project

  @app :growbox
  @version "0.1.0"

  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4, :x86_64]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      archives: [nerves_bootstrap: "~> 1.9"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      releases: [{@app, release()}],
      compilers: [:phoenix] ++ Mix.compilers(),
      preferred_cli_target: [run: :host, test: :host],
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Growbox.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Dependencies for all targets
      {:tzdata, "~> 1.1"},
      {:nerves, "~> 1.7.4", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},

      # Sensors and stuff
      {:circuits_gpio, "~> 0.4"},
      # {:pigpiox, "~> 0.1"},
      {:mcp300x, "~> 0.1.1"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.1", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi3, "~> 1.14.0", runtime: false, targets: :rpi3},
      {:nerves_system_x86_64, "~> 1.14.0", runtime: false, targets: :x86_64},

      # Phoenix dependencies
      {:ecto_sqlite3, "~> 0.5.4"},
      {:floki, ">= 0.27.0", only: :test},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.5.8"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.15.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:picam, "~> 0.4.0"},
      {:plug_cowboy, "~> 2.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets --legacy-peer-deps"],
      burn: ["cmd npm run deploy --prefix assets", "phx.digest", "firmware", "firmware.burn"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

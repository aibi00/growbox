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
      archives: [nerves_bootstrap: "~> 1.9"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      releases: [{@app, release()}],
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_target: [run: :host, test: :host],
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Growbox.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tzdata, "~> 1.0"},

      # Dependencies for all targets
      {:circuits_gpio, "~> 0.4"},
      {:nerves, "~> 1.7.4", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.1", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi3, "~> 1.14.0", runtime: false, targets: :rpi3},
      {:nerves_system_x86_64, "~> 1.14.0", runtime: false, targets: :x86_64},

      # Application dependencies
      {:phoenix_pubsub, "~> 2.0"},
      {:pigpiox, "~> 0.1"}
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

  defp aliases do
    [
      # (2)
      test: "test --no-start"
    ]
  end
end

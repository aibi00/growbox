defmodule Growbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    children =
      [
        {Phoenix.PubSub, name: Growbox.PubSub},
        GrowboxWeb.Telemetry,
        GrowboxWeb.Endpoint
      ] ++ children(target())

    opts = [strategy: :one_for_one, name: Growbox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Firmware.Worker.start_link(arg)
      # {Firmware.Worker, arg},
    ]
  end

  def children(_target) do
    Application.get_env(:growbox, :child_processes, [
      {Growbox.Lamp, 18},
      Growbox
    ])
  end

  def target() do
    Application.get_env(:firmware, :target)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GrowboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

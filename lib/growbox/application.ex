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
      Picam.FakeCamera
    ]
  end

  def children(_target) do
    Application.get_env(:growbox, :child_processes, [
      {Growbox.Lamp, 18},
      {Growbox.Pump, 4},
      {Growbox.SmallPump, [5, :water_pump]},
      {Growbox.SmallPump, [6, :ph_up_pump]},
      {Growbox.SmallPump, [16, :ph_down_pump]},
      {Growbox.SmallPump, [26, :nutrient_pump]},
      {Growbox.WaterLevel, [27, 22]},
      Picam.Camera
    ])
  end

  def target() do
    Application.get_env(:growbox, :target)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GrowboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

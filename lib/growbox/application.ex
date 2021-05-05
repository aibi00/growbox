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
        GrowboxWeb.Endpoint,
        Growbox.Database
      ] ++
        children(target()) ++
        Application.get_env(:growbox, :child_processes, [])

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

  # Stuff only booted on Raspberry Pi
  def children(_target) do
    [
      Pigpiox.Supervisor,
      {Growbox.Lamp, 18},
      {Growbox.Pump, 17},
      {Growbox.SmallPump, [5, :ec2_pump]},
      {Growbox.SmallPump, [6, :ph_up_pump]},
      {Growbox.SmallPump, [16, :ph_down_pump]},
      {Growbox.SmallPump, [26, :ec1_pump]},
      {Growbox.WaterLevel, [27, 22]},
      Picam.Camera,
      %{
        id: MCP300X.Server,
        start:
          {MCP300X.Server, :start_link, ["spidev0.0", MCP300X.MCP3008, [name: Growbox.MCP3008]]}
      },
      {Growbox.Temp, [5, 6, 7]},
      {Growbox.PH, 4},
      {Growbox.EC, 3}
    ]
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

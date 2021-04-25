defmodule Growbox.PH do
  use GenServer

  def start_link(channel) do
    GenServer.start_link(__MODULE__, channel)
  end

  def calc_ph(value) do
    volts = MCP300X.to_volts(value)
    Growbox.Helpers.map(volts, 1.599, 2, 4, 7)
  end

  def init(channel) do
    Process.send_after(self(), :tick, :timer.seconds(60))
    {:ok, channel}
  end

  def handle_info(:tick, channel) do
    if Growbox.alive?() do
      {:ok, value} = MCP300X.Server.read_channel(Growbox.MCP3008, channel)
      send(Growbox, {:ph, calc_ph(value)})
    end

    {:noreply, channel}
  end
end

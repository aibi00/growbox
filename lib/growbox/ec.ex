defmodule Growbox.EC do
  use GenServer

  def start_link(channel) do
    GenServer.start_link(__MODULE__, channel)
  end

  def calc_ec(value) do
    max = Growbox.Helpers.map(2.3, 0, 3.3, 0, 1023)
    Growbox.Helpers.map(value, 0, max, 0, 1000) / 640
  end

  def init(channel) do
    Process.send_after(self(), :tick, :timer.seconds(1))
    {:ok, channel}
  end

  def handle_info(:tick, channel) do
    {:ok, value} = MCP300X.Server.read_channel(Growbox.MCP3008, channel)
    Growbox.set_ec(calc_ec(value))
    {:noreply, channel}
  end
end

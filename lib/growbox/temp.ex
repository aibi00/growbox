defmodule Growbox.Temp do
  use GenServer

  def start_link(channels) do
    GenServer.start_link(__MODULE__, channels)
  end

  # not sure bout this
  @i 22.04 * :math.pow(10, -3)
  @r0 100
  @a 3.91 * :math.pow(10, -3)

  def calc_temp(value) do
    volts = MCP300X.to_volts(value)
    resistance = volts / @i

    (resistance - @r0) / (@r0 * @a)
  end

  def init(channels) do
    Process.send_after(self(), :tick, :timer.seconds(1))
    {:ok, channels}
  end

  def handle_info(:tick, channels) do
    if Growbox.alive?() do
      temperatures =
        for channel <- channels do
          {:ok, value} = MCP300X.Server.read_channel(Growbox.MCP3008, channel)
          calc_temp(value)
        end

      send(Growbox, {:temperature, Enum.max(temperatures)})
    end

    {:noreply, channels}
  end
end

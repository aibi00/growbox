defmodule Growbox.WaterLevel do
  use GenServer

  def start_link(max, min) do
    {:ok, max} = Circuits.GPIO.open(max, :input)
    {:ok, min} = Circuits.GPIO.open(min, :input)

    GenServer.start_link(__MODULE__, {max, min})
  end

  def init({max, min}) do
    Process.send_after(self(), :tick, :timer.seconds(1))
    {:ok, {max, min}}
  end

  def handle_info(:tick, {max, min}) do
    max_value = Circuits.GPIO.read(max)
    min_value = Circuits.GPIO.read(min)

    water_level =
      case {max_value, min_value} do
        {0, 0} -> :too_low
        {0, 1} -> :enough
        {1, 0} -> raise "impossibru"
        {1, 1} -> :too_high
      end

    Growbox.set_water_level(water_level)
    {:noreply, {max, min}}
  end
end

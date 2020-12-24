defmodule Growbox.SunLamp do
  use GenServer

  @timezone "Europe/Vienna"

  def start_link([]) do
    GenServer.start_link(__MODULE__, :off)
  end

  def on(pid) do
    GenServer.cast(pid, :on)
  end

  def off(pid) do
    GenServer.cast(pid, :off)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def init(state) do
    Process.send_after(self(), :tick, 0)
    {:ok, state}
  end

  def handle_cast(:on, _state) do
    {:noreply, on!()}
  end

  def handle_cast(:off, _state) do
    {:noreply, off!()}
  end

  def handle_call(:state, _parent, state) do
    {:reply, state, state}
  end

  def handle_info(:tick, _state) do
    datetime = Application.get_env(:growbox, :datetime, DateTime)

    time =
      apply(datetime, :now!, [@timezone])
      |> DateTime.to_time()

    state =
      if Time.compare(time, ~T[20:00:00]) == :lt && Time.compare(time, ~T[06:00:00]) == :gt do
        on!()
      else
        off!()
      end

    Process.send_after(self(), :tick, 1000)

    {:noreply, state}
  end

  defp on!() do
    # GPIO
    :on
  end

  defp off!() do
    # GPIO
    :off
  end
end

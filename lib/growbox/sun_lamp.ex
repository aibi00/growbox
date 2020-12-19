defmodule Growbox.SunLamp do
  use GenServer

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
    {:ok, state}
  end

  def handle_cast(:on, _state) do
    # GPIO
    {:noreply, :on}
  end

  def handle_cast(:off, _state) do
    # GPIO
    {:noreply, :off}
  end

  def handle_call(:state, _parent, state) do
    {:reply, state, state}
  end
end

defmodule Growbox.SunLamp do
  use GenServer

  @timezone "Europe/Vienna"

  def start_link(pin) do
    gpio = Application.get_env(:growbox, :gpio, Circuits.GPIO)
    pin = apply(gpio, :open, [pin, :output])

    GenServer.start_link(__MODULE__, %{lamp: :off, pin: pin})
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

  # GenServer API

  def init(state) do
    Process.send_after(self(), :tick, 0)
    {:ok, state}
  end

  def handle_cast(:on, state) do
    {:noreply, on!(state)}
  end

  def handle_cast(:off, state) do
    {:noreply, off!(state)}
  end

  def handle_call(:state, _parent, state) do
    {:reply, state.lamp, state}
  end

  def handle_info(:tick, state) do
    datetime = Application.get_env(:growbox, :datetime, DateTime)

    time =
      apply(datetime, :now!, [@timezone])
      |> DateTime.to_time()

    state =
      if Time.compare(time, ~T[20:00:00]) == :lt && Time.compare(time, ~T[06:00:00]) == :gt do
        on!(state)
      else
        off!(state)
      end

    Process.send_after(self(), :tick, 1000)

    {:noreply, state}
  end

  defp on!(state) do
    gpio_module = Application.get_env(:growbox, :gpio, Circuits.GPIO)
    apply(gpio_module, :write, [state.pin, 1])

    %{state | lamp: :on}
  end

  defp off!(state) do
    gpio_module = Application.get_env(:growbox, :gpio, Circuits.GPIO)
    apply(gpio_module, :write, [state.pin, 0])

    %{state | lamp: :off}
  end
end

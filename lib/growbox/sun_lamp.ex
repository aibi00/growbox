defmodule Growbox.SunLamp do
  use GenServer

  @timezone "Europe/Vienna"

  def start_link(pin) do
    {:ok, pin} = apply(gpio_module(), :open, [pin, :output])

    initial_state = %{lamp: :off, pin: pin}
    GenServer.start_link(__MODULE__, initial_state)
  end

  # Public API

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
    new_state = on!(state)
    {:noreply, new_state}
  end

  def handle_cast(:off, state) do
    new_state = off!(state)
    {:noreply, new_state}
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
      if Time.compare(time, ~T[06:00:00]) == :gt && Time.compare(time, ~T[20:00:00]) == :lt do
        on!(state)
      else
        off!(state)
      end

    Process.send_after(self(), :tick, 1000)

    {:noreply, state}
  end

  defp on!(state) do
    # Circuits.GPIO.write(state.pin, 1) in production
    # FakeGPIO.write(state.pin, 1) in tests
    apply(gpio_module(), :write, [state.pin, 1])

    %{state | lamp: :on}
  end

  defp off!(state) do
    apply(gpio_module(), :write, [state.pin, 0])

    %{state | lamp: :off}
  end

  defp gpio_module() do
    Application.get_env(:growbox, :gpio, Circuits.GPIO)
  end
end

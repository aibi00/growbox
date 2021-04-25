defmodule Growbox do
  use GenServer

  defstruct unixtime: 0,
            ec: 1.2,
            ph: 7.0,
            temperature: 20.0,
            water_level: :normal,
            # Components
            ec_pump: :off,
            lamp: :automatic_off,
            ph_down_pump: :off,
            ph_up_pump: :off,
            pump: :automatic_off,
            water_pump: :off,
            # From website
            brightness: 1.0,
            max_ec: 1.4,
            max_ph: 6.2,
            min_ph: 5.8,
            pump_off_time: 900,
            pump_on_time: 600

  def start_link(opts \\ []) do
    {now, _opts} = Keyword.pop(opts, :now, System.os_time(:second))

    {max_ec, _opts} = Keyword.pop(opts, :max_ec, %__MODULE__{}.max_ec)
    {max_ph, _opts} = Keyword.pop(opts, :max_ph, %__MODULE__{}.max_ph)
    {min_ph, _opts} = Keyword.pop(opts, :min_ph, %__MODULE__{}.min_ph)
    {pump_off_time, _opts} = Keyword.pop(opts, :pump_off_time, %__MODULE__{}.pump_off_time)
    {pump_on_time, _opts} = Keyword.pop(opts, :pump_on_time, %__MODULE__{}.pump_on_time)

    GenServer.start_link(
      __MODULE__,
      %Growbox{
        unixtime: now,
        max_ec: max_ec,
        max_ph: max_ph,
        min_ph: min_ph,
        pump_off_time: pump_off_time,
        pump_on_time: pump_on_time
      },
      name: __MODULE__
    )
  end

  def alive? do
    case Process.whereis(__MODULE__) do
      nil -> false
      _ -> true
    end
  end

  # Public API

  def manual_on(component) do
    GenServer.cast(__MODULE__, {:manual_on, component})
  end

  def manual_off(component) do
    GenServer.cast(__MODULE__, {:manual_off, component})
  end

  def set_brightness(value) do
    GenServer.cast(__MODULE__, {:brightness, value})
  end

  def set_pump_off_time(value) do
    GenServer.cast(__MODULE__, {:pump_off_time, value})
  end

  def set_pump_on_time(value) do
    GenServer.cast(__MODULE__, {:pump_on_time, value})
  end

  def set_max_ph(value) do
    GenServer.cast(__MODULE__, {:max_ph, value})
  end

  def set_min_ph(value) do
    GenServer.cast(__MODULE__, {:min_ph, value})
  end

  def set_max_ec(value) do
    GenServer.cast(__MODULE__, {:max_ec, value})
  end

  # GenServer API

  def init(state) do
    :timer.send_interval(:timer.seconds(1), :tick)
    Process.send_after(self(), {:automatic_on_or_off, :lamp}, 0)
    {:ok, state, {:continue, :broadcast}}
  end

  def handle_continue(:broadcast, state) do
    Phoenix.PubSub.broadcast(Growbox.PubSub, "growbox", state)
    {:noreply, state}
  end

  def handle_cast({:manual_on, :lamp}, state) do
    new_state =
      case state.lamp do
        :too_hot ->
          state

        _ ->
          Process.send_after(self(), {:automatic_on_or_off, :lamp}, :timer.minutes(10))
          %{state | lamp: :manual_on}
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:manual_off, :lamp}, state) do
    new_state =
      case state.lamp do
        :too_hot ->
          state

        _ ->
          Process.send_after(self(), {:automatic_on_or_off, :lamp}, :timer.minutes(10))
          %{state | lamp: :manual_off}
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:manual_on, :pump}, state) do
    new_state = %{
      state
      | pump: :manual_on,
        water_pump: :blocked,
        ph_up_pump: :blocked,
        ph_down_pump: :blocked,
        ec_pump: :blocked
    }

    Process.send_after(self(), {:automatic_on_or_off, :pump}, :timer.minutes(1))
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:manual_off, :pump}, state) do
    new_state = %{
      state
      | pump: :manual_off,
        water_pump: :blocked,
        ph_up_pump: :blocked,
        ph_down_pump: :blocked,
        ec_pump: :blocked
    }

    Process.send_after(self(), {:automatic_on_or_off, :pump}, :timer.minutes(1))
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:brightness, value}, state) do
    new_state = %{state | brightness: to_float(value)}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:max_ph, value}, state) do
    new_state = %{state | max_ph: to_float(value)}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:min_ph, value}, state) do
    new_state = %{state | min_ph: to_float(value)}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:max_ec, value}, state) do
    new_state = %{state | max_ec: to_float(value)}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:pump_off_time, value}, state) do
    new_state = %{state | pump_off_time: value}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:pump_on_time, value}, state) do
    new_state = %{state | pump_on_time: value}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:water_level, value}, state) do
    new_state =
      case value do
        :too_low ->
          %{state | water_pump: :on, water_level: value}

        :normal ->
          %{state | water_pump: :off, water_level: value}

        :too_high ->
          %{state | water_pump: :off, water_level: value}
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:temperature, value}, state) do
    new_state = %{state | temperature: to_float(value)}

    new_state =
      if value > 70 do
        %{new_state | lamp: :too_hot}
      else
        new_state
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info(:tick, state) do
    new_state = %{state | unixtime: System.os_time(:second)}
    new_state = %{new_state | pump: calc_pump_state(new_state)}

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:automatic_on_or_off, :lamp}, state) do
    new_state =
      case state.lamp do
        :too_hot -> state
        _ -> %{state | lamp: calc_lamp_state(state)}
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:automatic_on_or_off, :pump}, state) do
    new_state = %{state | pump: :automatic_off}
    new_state = %{new_state | pump: calc_pump_state(new_state)}

    new_state =
      case new_state.pump do
        :automatic_on ->
          %{
            new_state
            | water_pump: :blocked,
              ph_up_pump: :blocked,
              ph_down_pump: :blocked,
              ec_pump: :blocked
          }

        :automatic_off ->
          %{
            new_state
            | water_pump: :off,
              ph_up_pump: :off,
              ph_down_pump: :off,
              ec_pump: :off
          }
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:ec, value}, state) do
    new_state = %{state | ec: to_float(value)}

    new_state =
      if new_state.ec < state.max_ec do
        Process.send_after(self(), {:ec_pump, :off}, :timer.seconds(1))
        %{new_state | ec_pump: :on}
      else
        new_state
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:ph, value}, state) do
    new_state = %{state | ph: to_float(value)}

    new_state =
      cond do
        new_state.ph >= state.max_ph ->
          Process.send_after(self(), {:ph_down_pump, :off}, :timer.seconds(1))
          %{new_state | ph_down_pump: :on}

        new_state.ph <= state.min_ph ->
          Process.send_after(self(), {:ph_up_pump, :off}, :timer.seconds(1))
          %{new_state | ph_up_pump: :on}

        true ->
          new_state
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:ph_down_pump, :off}, state) do
    new_state = %{state | ph_down_pump: :off}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:ph_up_pump, :off}, state) do
    new_state = %{state | ph_up_pump: :off}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:ec_pump, :off}, state) do
    new_state = %{state | ec_pump: :off}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  # Helpers

  defp calc_lamp_state(state) do
    time =
      state.unixtime
      |> DateTime.from_unix!()
      |> DateTime.to_time()

    new_automatic_lamp_state =
      if Time.compare(time, ~T[06:00:00]) == :gt && Time.compare(time, ~T[20:00:00]) == :lt do
        :automatic_on
      else
        :automatic_off
      end

    case state.lamp do
      :automatic_on -> new_automatic_lamp_state
      :automatic_off -> new_automatic_lamp_state
      _ -> state.lamp
    end
  end

  def calc_pump_state(%Growbox{pump: pump_state} = state)
      when pump_state in [:automatic_on, :automatic_off] do
    # unixtime % pump_on + pump_off
    modulus = rem(state.unixtime, state.pump_off_time + state.pump_on_time)

    if modulus < state.pump_off_time do
      :automatic_off
    else
      :automatic_on
    end
  end

  def calc_pump_state(%Growbox{pump: pump_state} = state)
      when pump_state in [:manual_on, :manual_off] do
    state.pump
  end

  defp to_float(value), do: value / 1
end

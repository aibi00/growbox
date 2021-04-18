defmodule Growbox do
  use GenServer

  @timezone "Europe/Vienna"

  defstruct lamp: {:automatic, :off},
            temperature: 20,
            water_level: :normal,
            pump: {:automatic, :off},
            counter: 0,
            water_pump: :off,
            ph_up_pump: :off,
            ph_down_pump: :off,
            ec_pump: :off,
            ph: 7,
            ec: 1.2,
            # from website
            min_ph: 5.8,
            max_ph: 6.2,
            max_ec: 1.4,
            pump_on_time: 600,
            pump_off_time: 900,
            brightness: 1

  def start_link(_) do
    GenServer.start_link(__MODULE__, %Growbox{}, name: __MODULE__)
  end

  def start(_) do
    GenServer.start(__MODULE__, %Growbox{}, name: __MODULE__)
  end

  def stop() do
    __MODULE__ |> Process.whereis() |> Process.exit(:kill)
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
    Process.send_after(self(), {:automatic_on_or_off, :lamp}, 0)
    Process.send_after(self(), :tick, :timer.seconds(1))
    {:ok, state, {:continue, :broadcast}}
  end

  def handle_continue(:broadcast, state) do
    Phoenix.PubSub.broadcast(Growbox.PubSub, "growbox", state)
    {:noreply, state}
  end

  def handle_cast({:manual_on, :lamp}, state) do
    new_state =
      case state.lamp do
        {_, _} ->
          Process.send_after(self(), {:automatic_on_or_off, :lamp}, :timer.minutes(10))
          %{state | lamp: {:manual, :on}}

        :too_hot ->
          state
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:manual_off, :lamp}, state) do
    new_state =
      case state.lamp do
        {_, _} ->
          Process.send_after(self(), {:automatic_on_or_off, :lamp}, :timer.minutes(10))
          %{state | lamp: {:manual, :off}}

        :too_hot ->
          state
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:manual_on, :pump}, state) do
    new_state = %{
      state
      | pump: {:manual, :on},
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
      | pump: {:manual, :off},
        water_pump: :blocked,
        ph_up_pump: :blocked,
        ph_down_pump: :blocked,
        ec_pump: :blocked
    }

    Process.send_after(self(), {:automatic_on_or_off, :pump}, :timer.minutes(1))
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:brightness, value}, state) do
    new_state = %{state | brightness: value}
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

  def handle_cast({:max_ph, value}, state) do
    new_state = %{state | max_ph: value}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:min_ph, value}, state) do
    new_state = %{state | min_ph: value}
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_cast({:max_ec, value}, state) do
    new_state = %{state | max_ec: value}
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
    new_state =
      if value > 70 do
        %{state | lamp: :too_hot, temperature: value}
      else
        %{state | temperature: value}
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info(:tick, state) do
    new_state =
      case state.pump do
        {:automatic, _} -> %{state | counter: state.counter + 1}
        {_, _} -> state
      end

    new_state = %{new_state | pump: pump_cycle(new_state)}

    Process.send_after(self(), :tick, :timer.seconds(1))
    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:automatic_on_or_off, :lamp}, state) do
    new_state =
      case state.lamp do
        {_, _} -> %{state | lamp: {:automatic, lamp_on_or_off()}}
        :too_hot -> state
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:automatic_on_or_off, :pump}, state) do
    new_state = %{state | pump: {:automatic, :off}}
    new_state = %{new_state | pump: pump_cycle(new_state)}

    new_state =
      case new_state.pump do
        {:automatic, :on} ->
          %{
            new_state
            | water_pump: :blocked,
              ph_up_pump: :blocked,
              ph_down_pump: :blocked,
              ec_pump: :blocked
          }

        {:automatic, :off} ->
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
    new_state = %{state | ec: value}

    new_state =
      if(new_state.ec < state.max_ec) do
        Process.send_after(self(), {:ec_pump, :off}, :timer.seconds(1))
        %{new_state | ec_pump: :on}
      else
        new_state
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

  def handle_info({:ph, value}, state) do
    new_state = %{state | ph: value}

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

  defp lamp_on_or_off() do
    time =
      Application.get_env(:growbox, :datetime, DateTime)
      |> apply(:now!, [@timezone])
      |> DateTime.to_time()

    if Time.compare(time, ~T[06:00:00]) == :gt && Time.compare(time, ~T[20:00:00]) == :lt do
      :on
    else
      :off
    end
  end

  def pump_cycle(%Growbox{pump: {:automatic, _}} = state) do
    # counter % pump_on + pump_off
    modulus = rem(state.counter, state.pump_off_time + state.pump_on_time)

    if modulus < state.pump_off_time do
      {:automatic, :off}
    else
      {:automatic, :on}
    end
  end

  def pump_cycle(%Growbox{pump: {:manual, _}} = state) do
    state.pump
  end
end

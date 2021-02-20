defmodule Growbox do
  use GenServer

  @timezone "Europe/Vienna"

  defstruct lamp: {:automatic, :off}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %Growbox{}, name: __MODULE__)
  end

  # Public API

  def manual_on(component) do
    GenServer.cast(__MODULE__, {:manual_on, component})
  end

  def manual_off(component) do
    GenServer.cast(__MODULE__, {:manual_off, component})
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

  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, :timer.seconds(1))
    {:noreply, state, {:continue, :broadcast}}
  end

  def handle_info({:automatic_on_or_off, :lamp}, state) do
    new_state =
      case state.lamp do
        {_, _} -> %{state | lamp: {:automatic, lamp_on_or_off()}}
        :too_hot -> state
      end

    {:noreply, new_state, {:continue, :broadcast}}
  end

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
end

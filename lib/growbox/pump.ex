defmodule Growbox.Pump do
  use GenServer

  def start_link(pin) do
    gpio = Application.get_env(:growbox, :gpio, Circuits.GPIO)
    pin = apply(gpio, :open, [pin, :output])

    GenServer.start_link(__MODULE__, pin)
  end

  def init(pin) do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    {:ok, pin}
  end

  def handle_info(%Growbox{} = info, pin) do
    case info.pump do
      {_, :on} -> on!(pin)
      {_, :off} -> off!(pin)
    end

    {:noreply, pin}
  end

  defp on!(pin) do
    gpio_module = Application.get_env(:growbox, :gpio, Circuits.GPIO)
    apply(gpio_module, :write, [pin, 1])
  end

  defp off!(pin) do
    gpio_module = Application.get_env(:growbox, :gpio, Circuits.GPIO)
    apply(gpio_module, :write, [pin, 0])
  end
end

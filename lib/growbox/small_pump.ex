defmodule Growbox.SmallPump do
  use GenServer

  def start_link(pin, name) do
    gpio = Application.get_env(:growbox, :gpio, Circuits.GPIO)
    {:ok, pin} = apply(gpio, :open, [pin, :output])

    GenServer.start_link(__MODULE__, {pin, name})
  end

  def init({pin, name}) when is_reference(pin) do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    {:ok, {pin, name}}
  end

  def handle_info(%Growbox{} = info, {pin, name}) do
    case Map.fetch!(info, name) do
      :on -> on!(pin)
      :off -> off!(pin)
    end

    {:noreply, {pin, name}}
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

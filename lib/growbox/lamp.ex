defmodule Growbox.Lamp do
  use GenServer

  def start_link(pin) do
    {:ok, pin} = apply(gpio_module(), :open, [pin, :output])
    GenServer.start_link(__MODULE__, pin)
  end

  def init(pin) do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    {:ok, pin}
  end

  def handle_info(%Growbox{} = info, pin) do
    case info.lamp do
      {_, :on} -> on!(pin)
      _ -> off!(pin)
    end

    {:noreply, pin}
  end

  defp on!(pin) do
    # Circuits.GPIO.write(pin, 1) in production
    # FakeGPIO.write(pin, 1) in tests
    apply(gpio_module(), :write, [pin, 1])
  end

  defp off!(pin) do
    apply(gpio_module(), :write, [pin, 0])
  end

  defp gpio_module() do
    Application.get_env(:growbox, :gpio, Circuits.GPIO)
  end
end

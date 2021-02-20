defmodule Growbox.Lamp do
  use GenServer

  def start_link(pin) do
    GenServer.start_link(__MODULE__, pin)
  end

  def init(pin) do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    {:ok, pin}
  end

  def handle_info(%Growbox{} = info, pin) do
    brightness = info.brightness

    value =
      case info.lamp do
        {_, :on} -> round(brightness * 1_000_000)
        _ -> 0
      end

    apply(pwm_module(), :hardware_pwm, [pin, 800, value])

    {:noreply, pin}
  end

  defp pwm_module() do
    Application.get_env(:growbox, :pwm, Pigpiox.Pwm)
  end
end

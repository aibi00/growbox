defmodule FakePwm do
  use Agent

  def start_link(pid) do
    Agent.start_link(fn -> pid end, name: __MODULE__)
  end

  # Faked Pigpiox.Pwm API

  def hardware_pwm(gpio, frequency, level) do
    pid = Agent.get(__MODULE__, & &1)
    send(pid, {:hardware_pwm, [gpio, frequency, level]})
    :ok
  end
end

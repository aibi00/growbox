defmodule FakeDateTime do
  use Agent

  def start_link(time) do
    Agent.start_link(fn -> time end, name: __MODULE__)
  end

  def set(time) do
    Agent.update(__MODULE__, fn _ -> time end)
  end

  # Faked DateTime API

  def now!(_timezone) do
    Agent.get(__MODULE__, & &1)
  end
end

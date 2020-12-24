defmodule FakeGPIO do
  use Agent

  def start_link(pid) do
    Agent.start_link(fn -> pid end, name: __MODULE__)
  end

  # Faked GPIO API

  def open(pin, mode) do
    pid = Agent.get(__MODULE__, & &1)
    send(pid, {:open, [pin, mode]})
    {:ok, make_ref()}
  end

  def write(ref, value) do
    pid = Agent.get(__MODULE__, & &1)
    send(pid, {:write, [ref, value]})
    :ok
  end
end

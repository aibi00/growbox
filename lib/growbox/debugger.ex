defmodule Growbox.Debugger do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    {:ok, state}
  end

  def handle_info(%Growbox{} = msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end
end

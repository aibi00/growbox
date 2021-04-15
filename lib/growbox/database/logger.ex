defmodule Growbox.Logger do
  use GenServer
  alias Growbox.{Repo, Log}

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    {:ok, state}
  end

  def handle_info(%Growbox{} = msg, state) do
    Repo.insert!(Log.from_state(msg))
    {:noreply, state}
  end
end

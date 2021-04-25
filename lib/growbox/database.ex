defmodule Growbox.Database do
  use GenServer
  alias NimbleCSV.RFC4180, as: CSV

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    {:ok, File.open(database_file(), [:append, :delayed_write])}
  end

  def handle_info(%Growbox{} = msg, {:ok, file}) do
    IO.binwrite(file, CSV.dump_to_iodata([Map.values(msg)]))
    {:noreply, {:ok, file}}
  end

  def handle_info(%Growbox{} = _msg, state) do
    IO.warn("Can not write database file")
    {:noreply, state}
  end

  def terminate(_reason, {:ok, file} = state) do
    File.close(file)
    state
  end

  def terminate(_reason, state) do
    state
  end

  defp database_file() do
    Application.get_env(:growbox, :database_file, "database.csv")
  end
end

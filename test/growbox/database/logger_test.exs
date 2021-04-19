defmodule Growbox.LoggerTest do
  use ExUnit.Case, async: false
  alias Growbox.Logger

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Growbox.Repo)
    {:ok, _pid} = FakeDateTime.start_link(~U[2020-01-01 12:00:00.0Z])
    :ok
  end

  test "stores internal state in database" do
    {:ok, pid} = Logger.start_link([])
    Ecto.Adapters.SQL.Sandbox.allow(Growbox.Repo, self(), pid)

    assert Growbox.Repo.aggregate(Growbox.Log, :count) == 0
    start_supervised!(Growbox)

    :timer.sleep(50)
    assert Growbox.Repo.aggregate(Growbox.Log, :count) > 0
  end
end

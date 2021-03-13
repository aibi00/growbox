defmodule GrowboxWeb.HomeLiveTest do
  use GrowboxWeb.ConnCase
  import Phoenix.LiveViewTest

  setup do
    {:ok, _pid} = FakeDateTime.start_link(~U[2020-01-01 12:00:00.0Z])
    :ok
  end

  test "redirects to setup when Growbox is not running", %{conn: conn} do
    {:error, {:redirect, %{to: "/"}}} = live(conn, "/home")
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, _} = Growbox.start_link([])

    {:ok, page_live, disconnected_html} = live(conn, "/home")
    assert disconnected_html =~ "Temperature"
    assert render(page_live) =~ "Temperature"
  end
end

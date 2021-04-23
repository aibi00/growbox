defmodule GrowboxWeb.HomeLiveTest do
  use GrowboxWeb.ConnCase
  import Phoenix.LiveViewTest

  test "redirects to setup when Growbox is not running", %{conn: conn} do
    {:error, {:redirect, %{to: "/"}}} = live(conn, "/home")
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, _pid} = Growbox.start_link(now: DateTime.to_unix(~U[2020-01-01 12:00:00.0Z]))

    {:ok, page_live, disconnected_html} = live(conn, "/home")
    assert disconnected_html =~ "Temperature"
    assert render(page_live) =~ "Temperature"
  end
end

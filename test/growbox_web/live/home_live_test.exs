defmodule GrowboxWeb.HomeLiveTest do
  use GrowboxWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Temperature"
    assert render(page_live) =~ "Temperature"
  end
end

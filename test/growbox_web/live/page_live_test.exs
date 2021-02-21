defmodule GrowboxWeb.PageLiveTest do
  use GrowboxWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Growbox"
    assert render(page_live) =~ "Growbox"
  end
end

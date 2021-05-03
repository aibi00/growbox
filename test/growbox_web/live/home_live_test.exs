defmodule GrowboxWeb.HomeLiveTest do
  use GrowboxWeb.ConnCase
  import Phoenix.LiveViewTest

  test "redirects to setup when Growbox is not running", %{conn: conn} do
    {:error, {:redirect, %{to: "/"}}} = live(conn, "/home")
  end
end

defmodule GrowboxWeb.SetupRedirect do
  @moduledoc false

  alias GrowboxWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    if Growbox.alive?() do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: Routes.setup_path(conn, :index))
      |> Plug.Conn.halt()
    end
  end
end

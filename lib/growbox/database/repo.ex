defmodule Growbox.Repo do
  use Ecto.Repo, otp_app: :growbox, adapter: Ecto.Adapters.SQLite3
end

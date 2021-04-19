defmodule Growbox.Migrator do
  @moduledoc """
  A migrator for the production database.
  """

  @app :growbox

  def migrate do
    ensure_started()

    for repo <- repos() do
      run_migrations(repo, "migrations")
    end
  end

  def migrate_manual do
    ensure_started()

    for repo <- repos() do
      run_migrations(repo, "manual_migrations")
    end
  end

  def rollback(repo, version) do
    ensure_started()

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp run_migrations(repo, path) do
    {:ok, _, _} =
      Ecto.Migrator.with_repo(
        repo,
        &Ecto.Migrator.run(&1, Ecto.Migrator.migrations_path(repo, path), :up, all: true)
      )
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp ensure_started do
  end
end

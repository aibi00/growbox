defmodule Growbox.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :ec, :float, null: false
      add :ph, :float, null: false
      add :temperature, :float, null: false
      add :water_level, :string, null: false

      add :ec_pump, :jsonb, null: false
      add :lamp, :jsonb, null: false
      add :ph_down_pump, :jsonb, null: false
      add :ph_up_pump, :jsonb, null: false
      add :pump, :jsonb, null: false
      add :water_pump, :jsonb, null: false

      add :brightness, :float, null: false
      add :max_ec, :float, null: false
      add :max_ph, :float, null: false
      add :min_ph, :float, null: false
      add :pump_off_time, :integer, null: false
      add :pump_on_time, :integer, null: false

      timestamps()
    end
  end
end

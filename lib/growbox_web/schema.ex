defmodule Growbox.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:max_ec, :float)
    field(:max_ph, :float)
    field(:min_ph, :float)
    field(:pump_off_time, :integer)
    field(:pump_on_time, :integer)
    field(:max_temperature, :integer)
  end

  @doc false
  def changeset(attrs \\ {}) do
    defaults = %Growbox{}

    %__MODULE__{
      max_ec: defaults.max_ec,
      max_ph: defaults.max_ph,
      min_ph: defaults.min_ph,
      pump_off_time: defaults.pump_off_time,
      pump_on_time: defaults.pump_on_time,
      max_temperature: defaults.max_temperature
    }
    |> cast(attrs, [:max_ec, :max_ph, :min_ph, :pump_off_time, :pump_on_time, :max_temperature])
  end
end

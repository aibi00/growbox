defmodule Growbox.Log do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logs" do
    field :ec, :float
    field :ph, :float
    field :temperature, :float
    field :water_level, :string

    field :ec_pump, :string
    field :lamp, {:array, :string}
    field :ph_down_pump, :string
    field :ph_up_pump, :string
    field :pump, {:array, :string}
    field :water_pump, :string

    field :brightness, :float
    field :max_ec, :float
    field :max_ph, :float
    field :min_ph, :float
    field :pump_off_time, :integer
    field :pump_on_time, :integer

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [])
    |> validate_required([])
  end

  def from_state(%Growbox{} = state) do
    %__MODULE__{
      ec: state.ec,
      ph: state.ph,
      temperature: state.temperature,
      water_level: component_state_to_string(state.water_level),
      ec_pump: component_state_to_string(state.ec_pump),
      lamp: component_state_to_string(state.lamp),
      ph_down_pump: component_state_to_string(state.ph_down_pump),
      ph_up_pump: component_state_to_string(state.ph_up_pump),
      pump: component_state_to_string(state.pump),
      water_pump: component_state_to_string(state.water_pump),
      brightness: state.brightness,
      max_ec: state.max_ec,
      max_ph: state.max_ph,
      min_ph: state.min_ph,
      pump_off_time: state.pump_off_time,
      pump_on_time: state.pump_on_time
    }
  end

  defp component_state_to_string(state) when is_tuple(state) do
    state |> Tuple.to_list() |> Enum.map(&to_string(&1))
  end

  defp component_state_to_string(state) when is_atom(state) do
    to_string(state)
  end
end

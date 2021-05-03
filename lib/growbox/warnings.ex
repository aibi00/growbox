defmodule Growbox.Warnings do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    {:ok, []}
  end

  def handle_info(%Growbox{} = message, warnings) do
    new_warnings =
      case bad?(message) do
        false ->
          warnings

        warning ->
          if already_present?(warning, warnings) do
            warnings
          else
            [{warning, message} | warnings]
          end
      end

    {:noreply, new_warnings}
  end

  defp already_present?(warning, [{last_warning, _} | _]), do: warning == last_warning
  defp already_present?(_, _), do: false

  defp bad?(%Growbox{temperature: temperature, max_temperature: max_temperature})
       when temperature > max_temperature do
    :temperature
  end

  defp bad?(%Growbox{ec: ec, max_ec: max_ec}) when ec > max_ec do
    :ec
  end

  defp bad?(%Growbox{ph: ph, max_ph: max_ph}) when ph > max_ph do
    :ph
  end

  defp bad?(%Growbox{ph: ph, min_ph: min_ph}) when ph < min_ph do
    :ph
  end

  defp bad?(%Growbox{water_level: :impossibru}) do
    :water_level
  end

  defp bad?(%Growbox{water_level: :too_high}) do
    :water_level
  end

  defp bad?(_), do: false

  # Public API

  def all_warnings() do
    GenServer.call(__MODULE__, :warnings)
  end

  def clear_warnings() do
    GenServer.cast(__MODULE__, :clear)
  end

  def handle_cast(:clear, _warnings) do
    {:noreply, []}
  end

  def handle_call(:warnings, _from, warnings) do
    {:reply, warnings, warnings}
  end
end

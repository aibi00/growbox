defmodule GrowboxWeb.SetupLive do
  use GrowboxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if Growbox.alive?() do
      {:ok, redirect(socket, to: "/home")}
    else
      socket =
        socket
        |> assign(changeset: Growbox.Schema.changeset(%{}))

      {:ok, socket}
    end
  end

  @impl true
  def handle_params(_params, url, socket) do
    socket = socket |> assign(current_path: URI.parse(url).path)

    {:noreply, socket}
  end

  @impl true
  def handle_event("start", %{"schema" => params}, socket) do
    child_spec =
      {Growbox,
       [
         max_ec: elem(Float.parse(params["max_ec"]), 0),
         max_ph: elem(Float.parse(params["max_ph"]), 0),
         min_ph: elem(Float.parse(params["min_ph"]), 0),
         pump_off_time: elem(Integer.parse(params["pump_off_time"]), 0),
         pump_on_time: elem(Integer.parse(params["pump_on_time"]), 0)
       ]}

    socket =
      case Supervisor.start_child(Growbox.Supervisor, child_spec) do
        {:ok, _pid} -> redirect(socket, to: "/home")
        _ -> socket
      end

    {:noreply, socket}
  end

  def handle_event(_, _, socket) do
    {:noreply, socket}
  end
end

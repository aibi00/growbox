defmodule GrowboxWeb.HomeLive do
  use GrowboxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    end

    socket = socket |> assign(current_state: %Growbox{})

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, url, socket) do
    socket = socket |> assign(current_path: URI.parse(url).path)

    {:noreply, socket}
  end

  @impl true
  def handle_event("lamp-on", _params, socket) do
    Growbox.manual_on(:lamp)
    {:noreply, socket}
  end

  @impl true
  def handle_event("lamp-off", _params, socket) do
    Growbox.manual_off(:lamp)
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _params, socket) do
    Supervisor.terminate_child(Growbox.Supervisor, Growbox)
    Supervisor.delete_child(Growbox.Supervisor, Growbox)

    {:noreply, redirect(socket, to: Routes.setup_path(socket, :index))}
  end

  @impl true
  def handle_info(%Growbox{} = message, socket) do
    socket = socket |> assign(current_state: message)

    {:noreply, socket}
  end
end

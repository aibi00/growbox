defmodule GrowboxWeb.SetupLive do
  use GrowboxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if Growbox.alive?() do
      {:ok, redirect(socket, to: "/home")}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_params(_params, url, socket) do
    socket = socket |> assign(current_path: URI.parse(url).path)

    {:noreply, socket}
  end

  @impl true
  def handle_event("start", _, socket) do
    socket =
      case Supervisor.start_child(Growbox.Supervisor, Growbox) |> IO.inspect() do
        {:ok, _pid} -> redirect(socket, to: "/home")
        _ -> socket
      end

    {:noreply, socket}
  end
end

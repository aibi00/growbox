defmodule GrowboxWeb.WarningsLive do
  use GrowboxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
    end

    socket = socket |> assign(warnings: [])

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, url, socket) do
    socket = socket |> assign(current_path: URI.parse(url).path)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Growbox{}, socket) do
    socket = socket |> assign(warnings: Growbox.Warnings.all_warnings())

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _params, socket) do
    Growbox.Warnings.clear_warnings()
    socket = socket |> assign(warnings: [])
    {:noreply, socket}
  end
end

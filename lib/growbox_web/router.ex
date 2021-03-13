defmodule GrowboxWeb.Router do
  use GrowboxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GrowboxWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :requires_growbox_alive do
    plug GrowboxWeb.SetupRedirect
  end

  scope "/", GrowboxWeb do
    pipe_through :browser

    live "/", SetupLive, :index
  end

  scope "/", GrowboxWeb do
    pipe_through [:browser, :requires_growbox_alive]

    live "/home", HomeLive, :index
    live "/video", VideoCameraLive, :index
  end

  forward "/video.mjpg", GrowboxWeb.VideoCamera.Streamer

  # Other scopes may use custom stacks.
  # scope "/api", GrowboxWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GrowboxWeb.Telemetry
    end
  end
end

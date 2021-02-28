import Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

config :growbox, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1577975236"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger, :console]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
config :tzdata, :autoupdate, :disabled

# Phoenix configuration

# Configures the endpoint
config :growbox, GrowboxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RK4tj8xps4XLl1WZCI1+U22iyqOefXAmeFLx1cc0HTdPW6mFP7SVAUxUSExtH0Jw",
  render_errors: [view: GrowboxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Growbox.PubSub,
  live_view: [signing_salt: "1XpzdHRX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

if Mix.target() == :host or Mix.target() == :"" do
  import_config "host.exs"
else
  import_config "target.exs"
end

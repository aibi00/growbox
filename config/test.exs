import Config

config :growbox, :datetime, FakeDateTime
config :growbox, :gpio, FakeGPIO
config :growbox, :child_processes, []

# Phoenix configuration

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :growbox, GrowboxWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

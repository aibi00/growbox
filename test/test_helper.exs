Application.load(:growbox)

for app <- Application.spec(:growbox, :applications) do
  Application.ensure_all_started(app)
end

ExUnit.start()
Phoenix.PubSub.Supervisor.start_link(name: Growbox.PubSub)

# Add Toolshed helpers to the IEx session
use Toolshed

if RingLogger in Application.get_env(:logger, :backends, []) do
  RingLogger.attach()
end

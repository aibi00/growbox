defmodule Growbox.SunLampTest do
  use ExUnit.Case
  alias Growbox.SunLamp

  test "on" do
    {:ok, pid} = SunLamp.start_link([])
    SunLamp.on(pid)

    assert SunLamp.state(pid) == :on
  end

  test "off" do
    {:ok, pid} = SunLamp.start_link([])
    SunLamp.on(pid)

    assert SunLamp.state(pid) == :on
  end
end

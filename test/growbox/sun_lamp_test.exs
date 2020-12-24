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

  test "does not shine at night" do
    {:ok, _pid} = FakeDateTime.start_link(~U[2020-01-01 00:00:00.0Z])

    {:ok, pid} = SunLamp.start_link([])
    :timer.sleep(5)

    assert SunLamp.state(pid) == :off
  end

  test "does shine at day" do
    {:ok, _pid} = FakeDateTime.start_link(~U[2020-01-01 12:00:00.0Z])

    {:ok, pid} = SunLamp.start_link([])
    :timer.sleep(5)

    assert SunLamp.state(pid) == :on
  end
end

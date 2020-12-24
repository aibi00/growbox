defmodule Growbox.SunLampTest do
  use ExUnit.Case
  alias Growbox.SunLamp

  setup do
    {:ok, _agent} = FakeGPIO.start_link(self())
    :ok
  end

  test "on" do
    {:ok, pid} = SunLamp.start_link(18)
    SunLamp.on(pid)

    assert SunLamp.state(pid) == :on
    assert_receive {:open, [18, :output]}
    assert_receive {:write, [_ref, 1]}
  end

  test "off" do
    {:ok, pid} = SunLamp.start_link(18)
    SunLamp.off(pid)

    assert SunLamp.state(pid) == :off
    assert_receive {:open, [18, :output]}
    assert_receive {:write, [_ref, 0]}
  end

  test "does not shine at night" do
    {:ok, _pid} = FakeDateTime.start_link(~U[2020-01-01 00:00:00.0Z])

    {:ok, pid} = SunLamp.start_link(18)
    :timer.sleep(5)

    assert SunLamp.state(pid) == :off
    assert_receive {:open, [18, :output]}
    assert_receive {:write, [_ref, 0]}
  end

  test "does shine at day" do
    {:ok, _pid} = FakeDateTime.start_link(~U[2020-01-01 12:00:00.0Z])

    {:ok, pid} = SunLamp.start_link(18)
    :timer.sleep(5)

    assert SunLamp.state(pid) == :on
    assert_receive {:open, [18, :output]}
    assert_receive {:write, [_ref, 1]}
  end
end

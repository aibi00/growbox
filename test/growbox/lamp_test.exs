defmodule Growbox.LampTest do
  use ExUnit.Case
  alias Growbox.Lamp

  setup do
    {:ok, _agent} = FakePwm.start_link(self())
    :ok
  end

  test "receiving an on message" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: {:automatic, :on}})

    assert_receive {:hardware_pwm, [18, 800, 1_000_000]}
  end

  test "receiving an off message" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: {:manual, :off}})

    assert_receive {:hardware_pwm, [18, 800, 0]}
  end

  test "sets brightness to a proper value" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: {:manual, :on}, brightness: 0.3})

    assert_receive {:hardware_pwm, [18, 800, 300_000]}
  end
end

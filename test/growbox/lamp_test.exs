defmodule Growbox.LampTest do
  use ExUnit.Case
  alias Growbox.Lamp

  setup do
    {:ok, _agent} = FakePwm.start_link(self())
    :ok
  end

  test "receives a on message" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: :automatic_on})

    assert_receive {:hardware_pwm, [18, 800, 1_000_000]}
  end

  test "receives a off message" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: :manual_off})

    assert_receive {:hardware_pwm, [18, 800, 0]}
  end

  test "receives a too_hot message" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: :too_hot})

    assert_receive {:hardware_pwm, [18, 800, 0]}
  end

  test "sets brightness to a proper value" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: :manual_on, brightness: 0.3})

    assert_receive {:hardware_pwm, [18, 800, 300_000]}
  end
end

defmodule Growbox.SmallPumpTest do
  use ExUnit.Case
  alias Growbox.SmallPump

  setup do
    {:ok, _agent} = FakeGPIO.start_link(self())
    :ok
  end

  test "receiving an on message" do
    {:ok, pid} = SmallPump.start_link(4, :water_pump)
    send(pid, %Growbox{water_pump: :on})

    assert_receive {:open, [4, :output]}
    assert_receive {:write, [_ref, 1]}
  end

  test "receiving an off message" do
    {:ok, pid} = SmallPump.start_link(4, :water_pump)
    send(pid, %Growbox{water_pump: :off})

    assert_receive {:open, [4, :output]}
    assert_receive {:write, [_ref, 0]}
  end
end

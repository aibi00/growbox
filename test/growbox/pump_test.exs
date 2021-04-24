defmodule Growbox.PumpTest do
  use ExUnit.Case
  alias Growbox.Pump

  setup do
    {:ok, _agent} = FakeGPIO.start_link(self())
    :ok
  end

  test "receives an on message" do
    {:ok, pid} = Pump.start_link(4)
    send(pid, %Growbox{pump: :automatic_on})

    assert_receive {:open, [4, :output]}
    assert_receive {:write, [_ref, 1]}
  end

  test "receives an off message" do
    {:ok, pid} = Pump.start_link(4)
    send(pid, %Growbox{pump: :automatic_off})

    assert_receive {:open, [4, :output]}
    assert_receive {:write, [_ref, 0]}
  end
end

defmodule Growbox.PumpTest do
  use ExUnit.Case
  alias Growbox.Pump

  setup do
    {:ok, _agent} = FakeGPIO.start_link(self())
    :ok
  end

  test "eceiving an on message" do
    {:ok, pid} = Pump.start_link(4)

    send(pid, %Growbox{pump: {:automatic, :on}})
    assert_receive {:open, [4, :output]}
    assert_receive {:write, [_ref, 1]}
  end

  test "eceiving an off message" do
    {:ok, pid} = Pump.start_link(4)
    send(pid, %Growbox{pump: {:automatic, :off}})

    assert_receive {:open, [4, :output]}
    assert_receive {:write, [_ref, 0]}
  end
end

defmodule Growbox.LampTest do
  use ExUnit.Case
  alias Growbox.Lamp

  setup do
    {:ok, _agent} = FakeGPIO.start_link(self())
    :ok
  end

  test "receiving an on message" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: {:automatic, :on}})

    assert_receive {:open, [18, :output]}
    assert_receive {:write, [_ref, 1]}
  end

  test "receiving an off message" do
    {:ok, pid} = Lamp.start_link(18)
    send(pid, %Growbox{lamp: {:manual, :on}})

    assert_receive {:open, [18, :output]}
    assert_receive {:write, [_ref, 1]}
  end
end

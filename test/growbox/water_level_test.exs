defmodule Growbox.WaterLevelTest do
  use ExUnit.Case
  alias Growbox.WaterLevel

  setup do
    # https://github.com/elixir-circuits/circuits_gpio#testing
    {:ok, max} = Circuits.GPIO.open(0, :output)
    {:ok, min} = Circuits.GPIO.open(2, :output)

    start_supervised!(Growbox)

    {:ok, max: max, min: min}
  end

  test "reading both low", %{max: max, min: min} do
    {:ok, pid} = WaterLevel.start_link([1, 3])

    Circuits.GPIO.write(max, 0)
    Circuits.GPIO.write(min, 0)

    send(pid, :tick)
    :timer.sleep(5)

    assert %{water_level: :too_low} = :sys.get_state(Growbox)
  end

  test "reading only min high", %{max: max, min: min} do
    {:ok, pid} = WaterLevel.start_link([1, 3])

    Circuits.GPIO.write(max, 0)
    Circuits.GPIO.write(min, 1)

    send(pid, :tick)
    :timer.sleep(5)

    assert %{water_level: :normal} = :sys.get_state(Growbox)
  end

  test "reading only max high", %{max: max, min: min} do
    {:ok, pid} = WaterLevel.start_link([1, 3])

    Circuits.GPIO.write(max, 1)
    Circuits.GPIO.write(min, 0)

    send(pid, :tick)
    :timer.sleep(5)

    assert %{water_level: :impossibru} = :sys.get_state(Growbox)
  end

  test "reading both high", %{max: max, min: min} do
    {:ok, pid} = WaterLevel.start_link([1, 3])

    Circuits.GPIO.write(max, 1)
    Circuits.GPIO.write(min, 1)

    send(pid, :tick)
    :timer.sleep(5)

    assert %{water_level: :too_high} = :sys.get_state(Growbox)
  end
end

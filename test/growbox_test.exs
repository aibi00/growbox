defmodule GrowboxTest do
  use ExUnit.Case

  setup do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")
  end

  describe "start_link/1" do
    test "publishes state via pubsub" do
      Growbox.start_link([])
      assert_receive %Growbox{}
    end

    test "switches lamp automatically on during the day" do
      {:ok, _pid} = FakeDateTime.start_link(~U[2020-01-01 12:00:00.0Z])
      Growbox.start_link([])

      :timer.sleep(5)
      assert_receive %Growbox{lamp: {:automatic, :on}}
    end

    test "does nothing with the lamp during the night" do
      {:ok, _pid} = FakeDateTime.start_link(~U[2020-01-01 00:00:00.0Z])
      Growbox.start_link([])

      :timer.sleep(5)
      assert_receive %Growbox{lamp: {:automatic, :off}}
    end
  end

  describe "manual_on/1" do
    test "switches lamp on when in automatic mode" do
      Growbox.start_link([])
      Growbox.manual_on(:lamp)
      assert_receive %Growbox{lamp: {:manual, :on}}
    end

    test "switches lamp on when in manual mode" do
      Growbox.start_link([])
      # Set mode to manual
      Growbox.manual_on(:lamp)

      Growbox.manual_on(:lamp)
      assert_receive %Growbox{lamp: {:manual, :on}}
    end

    test "does nothing when lamp is too hot" do
      Growbox.start_link([])
      :sys.replace_state(Growbox, fn state -> %{state | lamp: :too_hot} end)

      Growbox.manual_on(:lamp)
      assert_receive %Growbox{lamp: :too_hot}
    end
  end

  describe "manual_off/1" do
    test "switches lamp off when in automatic mode" do
      Growbox.start_link([])
      Growbox.manual_off(:lamp)

      assert_receive %Growbox{lamp: {:manual, :off}}
    end

    test "switches lamp off when in manual mode" do
      Growbox.start_link([])
      # Set mode to manual
      Growbox.manual_off(:lamp)

      Growbox.manual_off(:lamp)
      assert_receive %Growbox{lamp: {:manual, :off}}
    end

    test "does nothing when lamp is too hot" do
      Growbox.start_link([])
      :sys.replace_state(Growbox, fn state -> %{state | lamp: :too_hot} end)

      Growbox.manual_off(:lamp)
      assert_receive %Growbox{lamp: :too_hot}
    end
  end

  describe "set_brightness/1" do
    test "sets brightness" do
      Growbox.start_link([])

      Growbox.set_brightness(0)
      assert_receive %Growbox{brightness: 0}

      Growbox.set_brightness(0.5)
      assert_receive %Growbox{brightness: 0.5}

      Growbox.set_brightness(1)
      assert_receive %Growbox{brightness: 1}
    end
  end

  describe "set_pump_on_time/1" do
    test "sets pump_on_time" do
      Growbox.start_link([])

      Growbox.set_pump_on_time(9001)
      assert_receive %Growbox{pump_on_time: 9001}
    end
  end

  describe "set_pump_off_time/1" do
    test "sets pump_off_time" do
      Growbox.start_link([])

      Growbox.set_pump_off_time(9001)
      assert_receive %Growbox{pump_off_time: 9001}
    end
  end

  describe "pump_cycle/1" do
    test "automatic mode" do
      default_state = %Growbox{
        pump: {:automatic, :off},
        pump_off_time: 15,
        pump_on_time: 10
      }

      assert Growbox.pump_cycle(%Growbox{default_state | counter: 0}) == {:automatic, :off}
      assert Growbox.pump_cycle(%Growbox{default_state | counter: 14}) == {:automatic, :off}
      assert Growbox.pump_cycle(%Growbox{default_state | counter: 15}) == {:automatic, :on}
      assert Growbox.pump_cycle(%Growbox{default_state | counter: 24}) == {:automatic, :on}
      assert Growbox.pump_cycle(%Growbox{default_state | counter: 25}) == {:automatic, :off}
    end

    test "manual mode" do
      default_state = %Growbox{
        pump: {:manual, :off},
        pump_off_time: 15,
        pump_on_time: 10
      }

      assert Growbox.pump_cycle(%Growbox{default_state | counter: 0}) ==
               {:manual, :off}

      assert Growbox.pump_cycle(%Growbox{default_state | pump: {:manual, :on}, counter: 0}) ==
               {:manual, :on}

      assert Growbox.pump_cycle(%Growbox{default_state | pump: {:manual, :on}, counter: 15}) ==
               {:manual, :on}
    end
  end

  describe "pump system" do
    setup do
      start_supervised!(Growbox)
      :ok
    end

    test "on startup the big pump is in automatic mode and the small ones are off" do
      assert %{
               pump: {:automatic, :off},
               nutrient_pump: :off,
               ph_down_pump: :off,
               ph_up_pump: :off,
               water_pump: :off
             } = :sys.get_state(Growbox)
    end

    test "when the big pump is manually working, smalls pumps are blocked" do
      Growbox.manual_on(:pump)

      assert %{
               pump: {:manual, :on},
               nutrient_pump: :blocked,
               ph_down_pump: :blocked,
               ph_up_pump: :blocked,
               water_pump: :blocked
             } = :sys.get_state(Growbox)
    end

    test "when the big pump is automatically on, smalls pumps are blocked" do
      :sys.replace_state(Growbox, fn state -> %{state | counter: 901} end)
      send(Growbox, {:automatic_on_or_off, :pump})

      assert %{
               pump: {:automatic, :on},
               nutrient_pump: :blocked,
               ph_down_pump: :blocked,
               ph_up_pump: :blocked,
               water_pump: :blocked
             } = :sys.get_state(Growbox)
    end

    test "when the big pump is manually off, smalls pumps are blocked" do
      Growbox.manual_off(:pump)

      assert %{
               pump: {:manual, :off},
               nutrient_pump: :blocked,
               ph_down_pump: :blocked,
               ph_up_pump: :blocked,
               water_pump: :blocked
             } = :sys.get_state(Growbox)
    end
  end
end

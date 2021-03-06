defmodule GrowboxTest do
  use ExUnit.Case

  setup env do
    Phoenix.PubSub.subscribe(Growbox.PubSub, "growbox")

    case env do
      %{datetime: datetime} -> start_supervised!({Growbox, unixtime: DateTime.to_unix(datetime)})
      _ -> start_supervised!(Growbox)
    end

    :ok
  end

  describe "start_link/1" do
    test "publishes state via pubsub" do
      assert_receive %Growbox{}
    end

    @tag datetime: ~U[2020-01-01 12:00:00.0Z]
    test "switches lamp automatically on during the day" do
      send(Growbox, {:automatic_on_or_off, :lamp})
      assert %{lamp: :automatic_on} = :sys.get_state(Growbox)
    end

    @tag datetime: ~U[2020-01-01 00:00:00.0Z]
    test "does nothing with the lamp during the night" do
      send(Growbox, {:automatic_on_or_off, :lamp})
      assert %{lamp: :automatic_off} = :sys.get_state(Growbox)
    end
  end

  describe "manual_on/1" do
    test "switches lamp on when in automatic mode" do
      :sys.replace_state(Growbox, fn state -> %{state | lamp: :automatic_off} end)

      Growbox.manual_on(:lamp)
      assert_receive %Growbox{lamp: :manual_on}
    end

    test "switches lamp on when in manual mode" do
      :sys.replace_state(Growbox, fn state -> %{state | lamp: :manual_off} end)

      Growbox.manual_on(:lamp)
      assert_receive %Growbox{lamp: :manual_on}
    end

    test "does nothing when lamp is too hot" do
      :sys.replace_state(Growbox, fn state -> %{state | lamp: :too_hot} end)

      Growbox.manual_on(:lamp)
      assert_receive %Growbox{lamp: :too_hot}
    end
  end

  describe "manual_off/1" do
    test "switches lamp off when in automatic mode" do
      :sys.replace_state(Growbox, fn state -> %{state | lamp: :automatic_on} end)

      Growbox.manual_off(:lamp)
      assert_receive %Growbox{lamp: :manual_off}
    end

    test "switches lamp off when in manual mode" do
      :sys.replace_state(Growbox, fn state -> %{state | lamp: :manual_on} end)

      Growbox.manual_off(:lamp)
      assert_receive %Growbox{lamp: :manual_off}
    end

    test "does nothing when lamp is too hot" do
      :sys.replace_state(Growbox, fn state -> %{state | lamp: :too_hot} end)

      Growbox.manual_off(:lamp)
      assert_receive %Growbox{lamp: :too_hot}
    end
  end

  describe "set values from website" do
    test "set_brightness/1" do
      Growbox.set_brightness(0)
      assert_receive %Growbox{brightness: 0.0}

      Growbox.set_brightness(0.5)
      assert_receive %Growbox{brightness: 0.5}

      Growbox.set_brightness(1)
      assert_receive %Growbox{brightness: 1.0}
    end

    test "set_max_ph/1" do
      Growbox.set_max_ph(9)
      assert_receive %Growbox{max_ph: 9.0}
    end

    test "set_min_ph/1" do
      Growbox.set_min_ph(3)
      assert_receive %Growbox{min_ph: 3.0}
    end

    test "set_max_ec/1" do
      Growbox.set_max_ec(2)
      assert_receive %Growbox{max_ec: 2.0}
    end

    test "set_pump_on_time/1" do
      Growbox.set_pump_on_time(9001)
      assert_receive %Growbox{pump_on_time: 9001}
    end

    test "set_pump_off_time/1" do
      Growbox.set_pump_off_time(9001)
      assert_receive %Growbox{pump_off_time: 9001}
    end
  end

  describe "calc_pump_state/1" do
    test "automatic mode" do
      default_state = %Growbox{
        pump: :automatic_off,
        pump_off_time: 15,
        pump_on_time: 10
      }

      assert Growbox.calc_pump_state(%Growbox{default_state | unixtime: 0}) == :automatic_off
      assert Growbox.calc_pump_state(%Growbox{default_state | unixtime: 14}) == :automatic_off
      assert Growbox.calc_pump_state(%Growbox{default_state | unixtime: 15}) == :automatic_on
      assert Growbox.calc_pump_state(%Growbox{default_state | unixtime: 24}) == :automatic_on
      assert Growbox.calc_pump_state(%Growbox{default_state | unixtime: 25}) == :automatic_off
    end

    test "manual mode" do
      default_state = %Growbox{
        pump: :manual_off,
        pump_off_time: 15,
        pump_on_time: 10
      }

      assert Growbox.calc_pump_state(%Growbox{default_state | unixtime: 0}) ==
               :manual_off

      assert Growbox.calc_pump_state(%Growbox{default_state | pump: :manual_on, unixtime: 0}) ==
               :manual_on

      assert Growbox.calc_pump_state(%Growbox{default_state | pump: :manual_on, unixtime: 15}) ==
               :manual_on
    end
  end

  describe "pump system" do
    test "on startup the big pump is in automatic mode and the small ones are off" do
      assert %{
               pump: :automatic_off,
               ec1_pump: :off,
               ph_down_pump: :off,
               ph_up_pump: :off,
               ec2_pump: :off
             } = :sys.get_state(Growbox)
    end

    test "when the big pump is manually working, smalls pumps are blocked" do
      Growbox.manual_on(:pump)

      assert %{
               pump: :manual_on,
               ec1_pump: :blocked,
               ph_down_pump: :blocked,
               ph_up_pump: :blocked,
               ec2_pump: :blocked
             } = :sys.get_state(Growbox)
    end

    test "when the big pump is automatically working, smalls pumps are blocked" do
      :sys.replace_state(Growbox, fn state -> %{state | unixtime: 901} end)
      send(Growbox, {:automatic_on_or_off, :pump})

      assert %{
               pump: :automatic_on,
               ec1_pump: :blocked,
               ph_down_pump: :blocked,
               ph_up_pump: :blocked,
               ec2_pump: :blocked
             } = :sys.get_state(Growbox)
    end

    test "when the big pump is manually on, smalls pumps are blocked" do
      Growbox.manual_on(:pump)

      assert %{
               pump: :manual_on,
               ec1_pump: :blocked,
               ph_down_pump: :blocked,
               ph_up_pump: :blocked,
               ec2_pump: :blocked
             } = :sys.get_state(Growbox)
    end

    test "when the big pump is manually off, smalls pumps are blocked" do
      Growbox.manual_off(:pump)

      assert %{
               pump: :manual_off,
               ec1_pump: :blocked,
               ph_down_pump: :blocked,
               ph_up_pump: :blocked,
               ec2_pump: :blocked
             } = :sys.get_state(Growbox)
    end
  end

  describe "sensor data" do
    test "receiving high pH value" do
      send(Growbox, {:ph, 6.4})
      assert %{ph_down_pump: :on, ph_up_pump: :off, ph: 6.4} = :sys.get_state(Growbox)
    end

    test "receiving normal pH value" do
      send(Growbox, {:ph, 6})
      assert %{ph_down_pump: :off, ph_up_pump: :off, ph: 6.0} = :sys.get_state(Growbox)
    end

    test "receiving low pH value" do
      send(Growbox, {:ph, 5.6})
      assert %{ph_down_pump: :off, ph_up_pump: :on, ph: 5.6} = :sys.get_state(Growbox)
    end

    test "receiving high ec value and 5am" do
      send(Growbox, {:ec, 1.6})
      assert %{ec1_pump: :off, ec: 1.6} = :sys.get_state(Growbox)
    end

    test "receiving high ec value and 6am" do
      Growbox.set_lamp_on_time(~T[06:00:00])
      send(Growbox, {:ec, 1.6})
      assert %{ec2_pump: :off, ec: 1.6} = :sys.get_state(Growbox)
    end

    test "receiving low ec value and 5am" do
      send(Growbox, {:ec, 1})
      assert %{ec1_pump: :on, ec: 1.0} = :sys.get_state(Growbox)
    end

    test "receiving low ec value and 6am" do
      Growbox.set_lamp_on_time(~T[06:00:00])
      send(Growbox, {:ec, 1})
      assert %{ec2_pump: :on, ec: 1.0} = :sys.get_state(Growbox)
    end

    test "receiving normal temperature" do
      lamp_state = :sys.get_state(Growbox).lamp
      send(Growbox, {:temperature, 65})
      assert %{temperature: 65.0, lamp: ^lamp_state} = :sys.get_state(Growbox)
    end

    test "receiving high temperature" do
      send(Growbox, {:temperature, 71})
      assert %{temperature: 71.0, lamp: :too_hot} = :sys.get_state(Growbox)
    end
  end
end

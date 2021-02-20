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
end

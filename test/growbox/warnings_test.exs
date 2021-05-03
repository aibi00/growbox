defmodule Growbox.WarningsTest do
  use ExUnit.Case
  alias Growbox.Warnings

  setup do
    start_supervised!(Warnings)
    :ok
  end

  describe "handle_info/2" do
    test "ignores state which is ok" do
      send(Warnings, %Growbox{})
      assert Warnings.all_warnings() == []
    end

    test "stores state if first occurrence of this warning" do
      send(Warnings, %Growbox{temperature: 100})
      assert length(Warnings.all_warnings()) == 1
    end

    test "ignores state if second occurrence of this warning" do
      send(Warnings, %Growbox{temperature: 100})
      send(Warnings, %Growbox{temperature: 101})
      assert length(Warnings.all_warnings()) == 1
    end

    test "stores state if different warnings" do
      send(Warnings, %Growbox{temperature: 100})
      send(Warnings, %Growbox{ph: 10})
      assert length(Warnings.all_warnings()) == 2
    end
  end
end

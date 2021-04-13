defmodule Growbox.HelpersTest do
  use ExUnit.Case
  alias Growbox.Helpers

  describe "map/5" do
    test "maps a value from one scale to another" do
      assert Helpers.map(0, 0, 10, 0, 100) == 0
      assert Helpers.map(5, 0, 10, 0, 100) == 50
      assert Helpers.map(10, 0, 10, 0, 100) == 100

      assert Helpers.map(0, 0, 10, 0, 1) == 0
      assert Helpers.map(5, 0, 10, 0, 1) == 0.5
      assert Helpers.map(10, 0, 10, 0, 1) == 1
    end
  end
end

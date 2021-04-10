defmodule Growbox.TempTest do
  use ExUnit.Case
  alias Growbox.Temp

  test "calc_temp/1 calculates temperature" do
    assert Temp.calc_temp(1023) >= 97 && Temp.calc_temp(1023) <= 103
  end
end

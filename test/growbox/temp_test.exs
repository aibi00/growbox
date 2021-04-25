defmodule Growbox.TempTest do
  use ExUnit.Case
  alias Growbox.Temp

  test "calc_temp/1 calculates temperature" do
    assert Temp.calc_temp(1023) >= 125 && Temp.calc_temp(1023) <= 129
  end
end

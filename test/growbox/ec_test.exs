defmodule Growbox.ECTest do
  use ExUnit.Case
  alias Growbox.EC

  describe "calc_ec/1" do
    test "calculate ec value" do
      assert EC.calc_ec(0) == 0
      assert EC.calc_ec(1023) > 1.5
    end
  end
end

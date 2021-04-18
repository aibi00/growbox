defmodule Growbox.PHTest do
  use ExUnit.Case
  alias Growbox.PH

  describe "calc_ph/1" do
    test "calculate ec value" do
      assert PH.calc_ph(620) == 7
      assert PH.calc_ph(496) > 4
    end
  end
end

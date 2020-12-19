defmodule GrowboxTest do
  use ExUnit.Case
  doctest Growbox

  test "greets the world" do
    assert Growbox.hello() == :world
  end
end

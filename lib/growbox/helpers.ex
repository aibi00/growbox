defmodule Growbox.Helpers do
  def map(_, in_min, in_max, _, _) when in_min == in_max, do: 0

  def map(value, in_min, in_max, out_min, out_max) do
    out_min + (out_max - out_min) * ((value - in_min) / (in_max - in_min))
  end
end

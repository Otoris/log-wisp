defmodule LogWispTest do
  use ExUnit.Case
  doctest LogWisp

  test "greets the world" do
    assert LogWisp.hello() == :world
  end
end

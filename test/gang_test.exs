defmodule GangTest do
  use ExUnit.Case
  doctest Gang

  test "greets the world" do
    assert Gang.hello() == :world
  end
end

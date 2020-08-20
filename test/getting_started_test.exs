defmodule GettingStartedTest do
  use ExUnit.Case
  doctest GettingStarted

  test "greets the world" do
    assert GettingStarted.hello() == :world
  end
end

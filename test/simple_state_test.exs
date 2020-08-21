defmodule SimpleStateTest do
    use ExUnit.Case
    doctest SimpleState 
    @tag timeout: 1000
  
    test "stores state" do
        pid = SimpleState.start('hello')
        assert Process.alive? pid
        assert SimpleState.get(pid) == 'hello'
        assert SimpleState.set(pid, 'world') == {:ok, 'world'}
        assert SimpleState.get(pid) == 'world'
    end
  end
  
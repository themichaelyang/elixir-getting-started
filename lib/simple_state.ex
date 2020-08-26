defmodule SimpleState do
  def start(init_state) do
    spawn fn -> loop(init_state) end
  end

  def get(pid) do
    send(pid, {:get, self()})
    receive do
      {:ok, state} -> state
    end
  end

  def set(pid, state) do
    # send msg to pid of state container, but receive in current proc
    send(pid, {:set, self(), state})
    receive do
      response -> response
    end
  end

  defp loop(state) do
    receive do 
      {:get, caller} -> send(caller, {:ok, state})
               loop(state)
      {:set, caller, new_state} ->
        send(caller, {:ok, new_state})
        loop(new_state)
    end
  end
end

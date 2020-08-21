# practicing to understand structs, enumerables
# and streams by reimplementing Enumerable

# continuations, accumulators, reduce

# Acc and Reduction seem to be not idiomatic Elixir, which seems
# to prefer raw tuples with leading atoms

# why :done, :halt and :suspend?
# see: https://elixir-lang.org/blog/2013/12/11/elixir-s-new-continuable-enumerators/
# and: https://hexdocs.pm/elixir/Enumerable.html#reduce/3

defmodule Acc do
    # https://stackoverflow.com/questions/41609368/enforce-all-keys-in-a-struct
    @enforce_keys [:instruction, :accumulated]
    defstruct @enforce_keys

    @type instruction :: :continue | :stop | :pause 
    @type t :: %Acc{instruction: instruction, accumulated: term}

    @spec continue(term) :: Acc.t
    def continue(acc) do
        %Acc{instruction: :continue, accumulated: acc}
    end

    @spec stop(term) :: Acc.t
    def stop(acc) do 
        %Acc{instruction: :stop, accumulated: acc}
    end

    @spec pause(term) :: Acc.t
    def pause(acc) do 
        %Acc{instruction: :pause, accumulated: acc}
    end
end

defmodule Reduction do
    @enforce_keys [:status, :result]
    defstruct @enforce_keys ++ [:continuation]

    @type status :: :done | :stopped | :paused
    @type t :: %Reduction{status: status, result: term, :continuation: term}

    def done(result) do
        %Reduction{status: :done, result: result}
    end
    
    def stopped(result) do
        %Reduction{status: :stopped, result: result}
    end
    
    def paused(result) do
        %Reduction{status: :paused, result: result}
    end
end

defmodule Iter do
    def map(iter, func) do
        iter |> reverse_map(&1) |> reverse_map(func)
    end
end

defprotocol Iterable do
    @spec reduce(term, Acc.t, (term, Acc.t -> term)) :: Reduction.t
    def reduce(iterable, accumulator, reducer)

    def reverse_map(iterable, func) do
        reducer = fn (item, acc) -> Acc.continue([func.(item) | acc]) end
        iterable |> Iterable.reduce(Acc.continue([]), reducer).result
    end
end


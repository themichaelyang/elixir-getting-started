# practicing to understand structs, enumerables
# and streams by reimplementing enumerable

# continuations, accumulateds, reduce

# acc and reduction seem to be not idiomatic elixir, which seems
# to prefer raw tuples with leading atoms

# why :done, :halt and :suspend?
# see: https://elixir-lang.org/blog/2013/12/11/elixir-s-new-continuable-enumerators/
# and: https://hexdocs.pm/elixir/enumerable.html#reduce/3

defprotocol Iterable do
    @type reducer (term, Step.t -> Step.t)

    defmodule Step do
        # https://stackoverflow.com/questions/41609368/enforce-all-keys-in-a-struct
        @enforce_keys [:instruction, :accumulated]
        defstruct @enforce_keys

        @type instruction :: :continue | :stop | :pause 
        @type t :: %Step{instruction: instruction, accumulated: term}

        def new(instr, acc) do
            %Step{instruction: instr, accumulated: acc}
        end

        def continue(step) do
            %Step{instruction: :continue, accumulated: step.accumulated}
        end
    end

    defmodule Reduction do
        @enforce_keys [:status, :result]
        @type status :: :done | :stopped | :paused
        @type continuation :: {term(), Step.t(), reducer()}
        @type t :: %Reduction{status: status, result: term | continuation}

        def new(status, result) do
            %Reduction{status: status, result: result}
        end
    end

    @spec reduce(term(), Step.t(), reducer()) :: Reduction.t()
    def reduce(iterable, step, reducer)

    def reverse_map(iterable, func) do
        reducer = fn (item, step) -> 
            next_acc = [func.(item) | step.acc]
            Step.new(instr, next_acc)
        end
        step = Step.new(:continue, [])
        iterable |> Iterable.reduce(step, reducer)
    end
    
    def map(iter, func) do
        iter |> reverse_map(&1) |> reverse_map(func)
    end
end

defimpl Iterable, for: List do
    def reduce([], step, reducer), do: Reduction.new(:done, [])
    def reduce(list, step = %step{instruction: :continue}, reducer) do
        [head | tail] = list
        new_acc = reducer(head, step.accumulated)
        reduce(tail, step.new(:continue, new_acc), reducer)
    end
    def reduce(list, step = %step{instruction: :stop}, reducer) do
        Reduction.new(:stopped, step.accumulated)
    end
    def reduce(list, step = %Step{instruction: :pause}, reducer) do
        # a continuation is a tuple of the params to reduce\3
        Reduction.new(:paused, {list, Step.continue(step), reducer})
    end
end


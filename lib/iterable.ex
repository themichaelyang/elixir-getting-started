# practicing to understand structs, enumerables
# and streams by reimplementing enumerable

# continuations, accumulateds, reduce

# acc and reduction seem to be not idiomatic elixir, which seems
# to prefer raw tuples with leading atoms

# why :done, :halt and :suspend?
# see: https://elixir-lang.org/blog/2013/12/11/elixir-s-new-continuable-enumerators/
# and: https://hexdocs.pm/elixir/enumerable.html#reduce/3

# scoping of modules still unclear (reducer type defined on parent module not being picked up in nested modules)
# ah! i think that is because module nesting is syntactic sugar, and doesn't actually relate the two
# so probably nesting reduce() ===> Iter.Iterable.reducer() which doesn't exist

defmodule Iter do
  @type reducer() :: (term, Step.t -> Step.t)

  # is this really necessary? why can't I define functions in protocols like a module
  # i guess this macro doesn't allow that. defimpl needed (see getting started)
  defprotocol Iterable do
    @type reducer() :: Iter.reducer
    @spec do_reduce(term(), Step.t(), reducer()) :: Reduction.t()
    def do_reduce(iterable, step, reducer)
  end

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
    defstruct @enforce_keys
    
    @type reducer() :: Iter.reducer
    @type status :: :done | :stopped | :paused
    @type continuation :: {term(), Step.t(), reducer()}
    @type t :: %Reduction{status: status, result: term | continuation}

    def new(status, result) do
      %Reduction{status: status, result: result}
    end
  end

  def reduce(iterable, init_acc, reducer) do
    wrapped_reducer = fn (element, step) -> 
      next_acc = reducer.(element, step.accumulated)
      Step.new(:continue, next_acc)
    end
    Iterable.do_reduce(iterable, Step.new(:continue, init_acc), wrapped_reducer).result
  end

  def reverse_map(iterable, func) do
    reducer = fn (item, step) -> 
      next_acc = [func.(item) | step.accumulated]
      Step.new(:continue, next_acc)
    end
    iterable |> Iterable.do_reduce(Step.new(:continue, []), reducer)
  end
  
  def map(iter, func) do
    iter |> reverse_map(&(&1)) |> reverse_map(func)
  end
end

defimpl Iter.Iterable, for: List do
  alias Iter.Step, as: Step
  alias Iter.Reduction, as: Reduction

  def do_reduce([], step, _reducer), do: Reduction.new(:done, step.accumulated)
  def do_reduce(list, step = %Step{instruction: :continue}, reducer) do
    [head | tail] = list
    do_reduce(tail, reducer.(head, step), reducer)
  end
  def do_reduce(_list, step = %Step{instruction: :stop}, _reducer) do
    Reduction.new(:stopped, step.accumulated)
  end
  def do_reduce(list, step = %Step{instruction: :pause}, reducer) do
    # a continuation is a tuple of the params to reduce\3
    Reduction.new(:paused, {list, Step.continue(step), reducer})
  end
end

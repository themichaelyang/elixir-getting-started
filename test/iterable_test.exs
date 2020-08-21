defmodule IterableTest do
    use ExUnit.Case

    test 'list is iterable' do
        sum_up = &(&1 + &2)
        assert [] |> Iter.reduce(0, sum_up) == 0
        assert [1, 2, 3, 4] |> Iter.reduce(0, sum_up) == 10
    end
end
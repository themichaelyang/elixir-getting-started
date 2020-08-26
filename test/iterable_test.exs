defmodule IterableTest do
  use ExUnit.Case

  test 'list is iterable' do
    sum_up = &(&1 + &2)
    assert [] |> Iter.reduce(0, sum_up) == 0
    assert [1, 2, 3, 4] |> Iter.reduce(0, sum_up) == 10
  end

  test 'list is mappable' do
    identity = &(&1)
    assert [1, 2, 3, 4] |> Iter.map(identity) == [1, 2, 3, 4]
    assert [1, 2, 3, 4] |> Iter.map(&(&1 * 2)) == [2, 4, 6, 8] 
  end
end

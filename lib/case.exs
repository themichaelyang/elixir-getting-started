# remember: single quotes are codepoints
# double quotes are UTF8
# both can use #{var} interpolation
# also: sigils

defmodule Cases do
  # interestingly, patterns cannot be stored in variables (but you could use a macro)
  def case_by_case(state) do
    case state do
      {:start, num} -> "matched number is" <> to_string(num)
      _ -> 'no match!'
    end
  end

  def cond_matching(state) do
    cond do
      match?({:start, _}, state) -> 
        "match is a macro that matched: #{state |> elem(1) |> to_string}"
        # string interpolation!
      true -> "no match!"
    end
  end

  def main() do
    # tuples must be pattern matched with same "shape"
    state = {:start, 1} 
    state |> case_by_case |> IO.puts
    IO.puts cond_matching state

    # maps can pattern match subsets with attributes (note that keyword lists are diff)
    # structs too, since structs are maps
    mapping = %{:first => 1, :second => 2}
    case mapping do
      %{:first => 1, :second => s} -> "second char is " <> to_string(s)
      %{} -> "this matches every map"
    end |> IO.puts
  end
end

# def must exist in modules!
Cases.main

defmodule FizzBuzz do
  @moduledoc false

  def print() do
    1..100 |> Enum.map( fn(x) ->
      cond do
        rem(x, 15) == 0 -> "FizzBuzz"
        rem(x, 3) == 0 -> "Fizz"
        rem(x, 5) == 0 -> "Buzz"
        true -> x
      end
    end) |> Enum.each(fn(x) -> IO.puts(x) end)
  end
end
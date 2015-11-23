defmodule FizzBuzz do

    def upto(n) when n > 0 , do:
    _downto(n, [])

    defp _downto(0, result), do: result

    defp _downto(current , result) do

        next_answer =
            cond do
                rem(current,  3) == 0
                and rem(curren , 5) == 0 ->

                "FizzBuzz"

                rem(curren , 3) == 0
                -> "fizz"
                rem(current , 5) == 0
                ->
                    "Buzz"
                    true ->
                    curren
                    end

                    _downto(current -1 , [next_anser | result])

         end

end
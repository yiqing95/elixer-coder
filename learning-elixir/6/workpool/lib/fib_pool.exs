defmodule FibonacciWorkPool do
    def fib(fibonacci_digits) do
        fibonacci_digits |>
        Enum.map(fn(n) -> Workpool.queue(&fib_comp/1, n) end)
    end

    # Terribly slow version
    defp fib_comp(0), do: 0
    defp fib_comp(1), do: 1
    defp fib_comp(n), do: fib_comp(n-1) + fib_comp(n-2)
end
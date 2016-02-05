defmodule Math do
   @moduledoc """
          Provides math-related functions
          """

    @doc"""
    Calculate factorial of a number .

    ## Example

        iex> Math.factorial(5)
        120
    """
    def factorial(n), do: do_factorial(n)

    defp do_factorial(0), do: 1
    defp do_factorial(n), do: n * do_factorial(n-1)

    @doc """
    Compute the binomial coefficient of `n` 和 `k`

    ## Example
        iex> Math.binomial(4, 2)
        6
    """
    def binomial(n,k), do: div(factorial(n), factorial(k)* factorial(n-k))
end
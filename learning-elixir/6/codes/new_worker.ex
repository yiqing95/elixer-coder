defmodule NewWorker do
  def start do
    spawn(fn -> loop() end)
  end
defp loop do
  receive do
   {:ping, sender} ->
      send sender, {:pong, self}
      loop()
  {:compute, n, sender} ->
      send sender, {:result, fib(n)}
      loop()
  end
end
defp fib(0), do: 0
defp fib(1), do: 1
defp fib(n), do: fib(n-1) + fib(n-2)
end
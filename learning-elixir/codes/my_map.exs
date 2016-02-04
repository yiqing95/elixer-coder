defmodule MyMap do
    def map([], _) do
        []
    end

    def map([h|t], f) do
        [f.(h) | map(t, f)]
    end
end

square = fn x -> x * x end
MyMap.map(1..5, square)
defmodule MyMap do
  @moduledoc false

  def pmap(collection , f) do
    collection |>
    Enum.map(&(Task.async(fn -> f.(&1) end )) ) |>
    Enum.map(&Task.await/1)
  end
end
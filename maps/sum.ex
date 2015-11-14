defmodule Sum do
  @moduledoc false

    def values(dict ) do
      dict |> Dict.values |> Enum.sum
    end

end
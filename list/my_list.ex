defmodule MyList do
  @moduledoc false

  def len([]) , do: 0

  def len([_head | tail ]) , do: 1 + len(tail)



end
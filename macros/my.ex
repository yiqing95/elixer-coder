defmodule My do
  @moduledoc false

  def myif(confition, clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)
    case condition do
      val when val in [false,  nil]
        -> else_clause
      _otherwise
          -> do_clause
       end
  end

end
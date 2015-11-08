defmodule Test do
  @moduledoc false

  def greet(greeting,name) , do: (
    IO.puts greeting
    IO.puts "How're you doning , #{name}? "

  )

end
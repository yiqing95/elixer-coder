defmodule DemoDefp do
  @moduledoc false

  def f1() , do: (
      IO.puts "this si public function of this module "
      _f()
  )

  defp _f() , do: (
        IO.puts "this is protected method of this module "
  )

end
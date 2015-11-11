defmodule Mod do
  @moduledoc false

  def func1 do

    IO.puts "in func1 "
  end

  def func2 do
    func1
    IO.puts "in func2"
  end

end

Mod.func1
Mod.func2
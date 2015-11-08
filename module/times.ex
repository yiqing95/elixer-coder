defmodule Times do
  @moduledoc false

  def double(n) do
     n*2
  end

  def foo(n) do
      IO.puts(n)
  end

  # 同名方法的重载 参数个数不一样的！
  def foo(p1,p2) do
      IO.puts(" p1 : #{p1} , p2 : #{p2}")
  end
  
end
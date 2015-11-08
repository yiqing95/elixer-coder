defmodule Factorial2 do
  @moduledoc false

  def of(0) , do: 1
  # 有guard的 定义
  def of(n) when n>0 do
    n * of(n-1)
  end

end
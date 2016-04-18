defmodule Example do
  @moduledoc false

  @author "yiqing"

  def get_author do
    @author
  end

  # 可以定义多次
  @attr "one"

  def first , do: @attr

  @attr "two"

  def second , do: @attr

end

IO.puts "Example written by #{Example.get_author}"

# 多次定义的属性输出
IO.puts " #{Example.first} #{Example.second} "

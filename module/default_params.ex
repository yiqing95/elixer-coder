defmodule DefaultParams do
  @moduledoc false

  # 此函数如果出现在下面函数之后 会报错的！ 由于下面的函数 匹配 2-4 个参数
  def func(p1,99) , do: (IO.puts "you said 99")
  
  # 函数 参数默认值 匹配规则： 从左向右
  def func(p1 , p2 \\ 2 ,p3 \\ 3 ,p4 ) do
    IO.inspect [p1,p2,p3,p4]
  end

end
defmodule DemoPipiline do
  @moduledoc false

  def demo() , do: (
    # 在管道操作中 方法参数最好都用括号括起来
    # IO.puts (1..10) |> Enum.map(&(&1*&1)) |> Enum.filter(&(&1 < 40 ))
    (1..10) |> Enum.map(&(&1*&1)) |> Enum.filter(&(&1 < 40 )) |> IO.inspect

  )

  def f1(), do: (
     # 方法用的装饰器类似的效果 不然不易看出来调用情况
    "this p will be passed to f2" |> f2 |> f3
  )

   def f2(p) do
       # IO.puts "this is the function f2 #{p} "

        " f2[[ #{p}  ]]"
    end

    def f3(p) ,do: (
      # IO.puts "this is the function f3 #{p} "
       " f3[[ #{p} ]]"
    )

end
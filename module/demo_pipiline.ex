defmodule DemoPipiline do
  @moduledoc false

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
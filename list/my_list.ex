defmodule MyList do
  @moduledoc false

  def len([]) , do: 0

  def len([_head | tail ]) , do: 1 + len(tail)

  #  对某个整数的列表 返回一个新的列表 元素是原先响应位上的平方
  def square([]) , do: []
  #  递归
  def square([head|tail]) , do: [ head * head | square( tail ) ]


  # 对列表中的每个元素自身增1
  def add_1( [] ) , do: []
  def add_1([ head | tail ]) , do: [ head+1 | add_1(tail) ]


  ##  著名的 Map 函数
  def  map([], _func) , do: []
  def  map([head | tail ] ,func) ,do: [ func.(head) | map(tail,func) ]


  def sum(list) , do: _sum(list,0)  # def sum([head | tail ]) , do: _sum( [head | tail ] , 0 )
  ## 私有函数
  ## 定义求和计算 调用时 需要传递一个将被求和的列表和一个初始总数（0）
  defp _sum( [] , total ) , do: total
  defp _sum( [ head | tail ] , total) , do: _sum(tail , head + total )


end
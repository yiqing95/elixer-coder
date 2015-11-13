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
end
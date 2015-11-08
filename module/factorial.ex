defmodule Factorial do
  @moduledoc false

  def of(0) , do: 1
  # 计算阶乘 递归定义 注意同名函数的匹配问题 不能把此定义放在f(0) 之前  这个跟异常类型匹配一样 越宽泛的匹配 越要出现在后面
  # elixir 对同名函数的匹配 是从上至下
  def of(n) , do: n * of(n-1)

end
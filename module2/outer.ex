defmodule Outer do
  @moduledoc false

  defmodule Inner do
      def inner_func do
        IO.puts  "hi this is a inner func inside the inner module "
      end
  end

  def outer_func do
      Inner.inner_func
  end

end

## 调用

Outer.outer_func

# 调用模块内部模块的方法

Outer.Inner.inner_func
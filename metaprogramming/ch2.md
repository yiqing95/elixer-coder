~~~

    defmodule Assertion do
        # {:==, [context: Elixir, import: kernel] ,[5, 5]}
        defmacro assert({operator, _, [lhs,rhs]}) do
            quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
                Assertion.Test.assert(operator, lhs, rhs)
            end
        end
    end
~~~
### bind_quoted
quote宏的bind_quoted 选项传递一个绑定块，确保外部绑定变量只被unquoted一次。

下面两种等价:
>   
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
        Assertion.Test.assert(operator, lhs, rhs)
    end

>
    quote do
        Assert.Test.assert(unquote(operator), unquote(lhs), unquote(rhs) )
    end

注意当使用bind_quoted 时unquote就不可用了！你不能使用unquote宏除非你显式传递unquote:true选项给quote    

## 扩展模块
宏核心目标之一就是注入代码到模块中来扩展其行为，定义函数，执行任何其他需要的代码生成

## 模块扩展只是简单的代码注入

~~~

    defmodule Assertion do
        # ...
        defmacro extend(options \\ []) do
            quote do
                import unquote(__MODULE__)
    
                def run do
                    IO.puts "Running the tests ..."
                end
            end
        end
    end
    
    defmodule MathTest do
        require Assertion
        Assertion.extend
    end
    
    #
    '''
    iex(23)> c "module_extension_custom.exs"
    module_extension_custom.exs:1: warning: redefining module Assertion
    module_extension_custom.exs:3: warning: variable options is unused
    module_extension_custom.exs:14: warning: redefining module MathTest
    [MathTest, Assertion]
    iex(24)> MathTest.run
    Running the tests ...
    :ok
    '''
~~~
我们可以注入run函数桩直接到MathTest模块中 通过使用Assertion.extend 宏。

## use ： 通用的API用于扩展模块

很多库中你都会看到 **use SomeModule** 语法，use宏提供了简单但强大目的 提供一个公共API来做模块扩展。
use SomeModule 简单调用SomeModule.__using__/1 宏。
通过提供公共API用于扩展，此很小的宏会成为元编程的中心。
~~~

    defmodule Assertion do
    #...
        defmacro __using__(_options) do
            quote do
                import unquote(__MODULE__)
    
                def run do
                    IO.puts "Running the tests..."
                end
            end
        end
    end
    
    defmodule MathTest do
        use Assertion
    end
    
    iex(25)> c "module_extension_use.exs"
    module_extension_use.exs:1: warning: redefining module Assertion
    module_extension_use.exs:14: warning: redefining module MathTest
    [MathTest, Assertion]
    iex(26)> MathTest.run
    Running the tests...
    :ok
~~~
我们使用use和__using__ Elixir的公共API 来扩展MathTest模块 。此结果等同我们上例中的Assertion.extend 例子。
但使用use 符合Elixir的公共api惯用法 对未来的变化更具灵活性。

use 实际只是一个宏，它同我们的extend定义那样做了一些代码注入
use只是常规宏的实事真正展示了Elixir坚持是一个通过宏构建的小语言。

## 对代码生成使用模块属性

模块属性允许数据在编译期被存储在模块中。他们经常被用在其他语言中常量出现的位置。
~~~

    defmodule Assertion do
    
        defmacro __using__(_options) do
            quote do
                import unquote(__MODULE__)
                Module.register_attribute __MODULE__, :tests, accumulate: true
                def run do
                    IO.puts "Running the tests (#{inspect @tests})"
                end
            end
        end
    
        defmacro test(description, do: test_block) do
            test_func = String.to_atom(description)
            quote do
                @tests {unquote(test_func), unquote(description)}
                def unquote(test_func)(), do: unquote(test_block)
            end
        end
    end
~~~
我们需要延迟宏展开直到某些代码生成工作之后。Elixir为此目的提供了before_compile 钩子

## Compile-Time Hooks
Elixir运行我们设定某个特定的模块属性。@before_compile,来通知编译器 一个特定的不住需要在编译之前完成。
@before_compile 属性接受一个模块参数 模块必须定义一个__before_compile__/1 宏。 此宏在编译前被执行为了执行最后一点代码生成
~~~

    defmodule Assertion do
    
      defmacro assert({operator, _, [lhs, rhs]}) do
            quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
                Assertion.Test.assert(operator, lhs, rhs)
            end
      end
    
        defmacro __using__(_options) do
            quote do
                import unquote(__MODULE__)
                Module.register_attribute __MODULE__, :tests, accumulate: true
                @before_compile unquote(__MODULE__)
            end
        end
    
        defmacro __before_compile__(_env) do
            quote do
                def run do
                    IO.puts "Running the tests (#{inspect @tests})"
                end
            end
        end
    
        defmacro test(description, do: test_block) do
            test_func = String.to_atom(description)
            quote do
                @tests {unquote(test_func), unquote(description)}
                def unquote(test_func)(), do: unquote(test_block)
            end
        end
        # ...
    end
~~~
我们注册了一个before_compile 属性钩子 来让Assert.__before_compile__/1在MathTest被编译完前执行，这让我们的accumulated @tests
属性被合适的扩展 ，因为它定义在test-case 注册之后。


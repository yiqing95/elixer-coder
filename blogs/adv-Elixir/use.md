Linking Modules: Behavio(u)rs and Use
-------------------

~~~
    
    defmodule Sequence.Server do
        use GenServer
        ...
~~~
use GenServer 真正做了什么？我们如可设计模块来扩展其他模块的功能（use 他们的）

## Behaviours
Elixir behaviour 只是一些函数的列表。声明他们的模块必须实现所有的关联函数，不然，Elixir就会出现编译错误。
behaviours 有点像Java中的interface。使用它的模块声明它实现了特定接口。比如，一个OTP GenServer 应该实现一些标准的回调集合。
（handle_call, handle_cast ,... 等），通过声明我们的模块实现了这些behaviour ，我们可以让编译器验证我们确实提供了必要的
接口。这样减低了运行时出现未预期错误的机会。

## Defining Behaviours
我们使用Elixir的Behaviour模块和defcallback 来定义behaviour。
 
 比如 Elixir自带的URI解析库，这个库委托一些函数到 协议特定【protocol-specific】的库（有一些用于HTTP，一个用于FTP，等）
 这些协议规格库必须定义两个函数：parse和default_port
 
 到这些子库的接口被定义在URI.Parser 模块，看起来像这样：
 ~~~
    
    defmodule URI.Parser do
        @moduledoc """
        Defines the behavior for each URI.Parser.
        Check URI.HTTP for a possible implementation.
        """
        use Behavior
        @doc """
        Responsible for parsing extra URL information.
        """
        defcallback parse(uri_info :: URI.Info.t) :: URI.Info.t
        @doc """
        Responsible for returning the default port .
        """
        defcallback default_port() :: integer
    end
 ~~~
 此模块定义了那些实现behaviour的模块必须支持的接口，
 有两点，一 有一行 use Behaviour 这添加了我们需要定义行为添加的功能。
 接下来，使用defcallback来定义行为中的函数。但语法看起来有点不同，这是因为我们使用了一个minilanguage: Erlang 类型规范。 
 比如 parse函数接受一个独参，应该是一个URI.Info 记录，它的返回值也应该是相同的类型。default_port 函数没有参数 返回一个整数。
 
 除了类型规范，我们可以包括模块和函数级别的文档 和我们的行为定义一起。
 
 定义好行为之后，我们可以声明一些模块实现它 通过使用@behaviour属性。
 ~~~
 
    defmodule URI.HTTP do
        @behaviour URI.Parser
        def default_port(), do: 80
        def parse(info), do: info
    end
  ~~~
  此模块可以干净的编译，假设我们拼写错误了:default_port:
  ~~~
  
    defmodule URI.HTTP do
        @behaviour URI.Parser
        
        def default_prot(), do: 80
        def parse(info), do: info
    end
  
  ~~~
当编译时 会报错的！
  
behaviours 给我们一种方式 来文档化 和 强制模块应该实现的公共函数  

## Use 和 __using__
某种意义，use 是一个琐碎的函数，你传递一个模块 和一个可选的参数，他就在模块中 调用函数 或者使用 __using__ 宏，传递给他参数。

然而这是简单的接口给你一种扩展能力。比如 在我们的单元测试中我们 use ExUnit.Case 我们会得到test宏和assertion支持。当我们
写了一个OTP server，我们 use GenServer 得到文档化gen_server callback的行为 和这些回调的默认实现。

典型地，__using__ 回调会被实现为一个宏，英文他会被用来在原始模块中调用代码。

放在一起 --- 跟踪代码调用
==========
我们想实现一个Tracer模块 ，如果在其他模块中使用它 use Tracer ,进入或者退出跟踪 会被添加给会被添加
给任何后续的函数定义。比如：
~~~
    
    defmodule Test do
        use Tracer
        def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
        def add_list(list), do: Enum.reduce(list, 0, &(&1+&2))
    end
    Test.puts_sum_three(1,2,3)
    Test.add_list([5,6,7,8])
~~~
要跟踪方法调用 看似我们需要重写掉def 宏。它被定义在Kernel中，让我们来看看当定义一个方法时传递给def了什么。

~~~
    
       defmodule Tracer do
           defmacro def(definition, do: _content) do
               IO.inspect definition
               quote do: {}
           end
       end
       defmodule Test do
           import Kernel, except: [def: 2]
           import Tracer, only: [def: 2]
           def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
           def add_list(list),        do: Enum.reduce(list, 0, &(&1 + &2))
       end
       
       Test.puts_sum_three(1,2,3)
       Test.add_list([ 5, 6, 7])
   
    iex(2)> c("use/tracer1.ex")
    {:puts_sum_three, [line: 10],
     [{:a, [line: 10], nil}, {:b, [line: 10], nil}, {:c, [line: 10], nil}]}
    {:add_list, [line: 11], [{:list, [line: 11], nil}]}
    
    == Compilation error on file use/tracer1.ex ==
    ** (UndefinedFunctionError) undefined function: Test.puts_sum_three/3
        Test.puts_sum_three(1, 2, 3)
        use/tracer1.ex:14: (file)
        (elixir) lib/kernel/parallel_compiler.ex:98: anonymous fn/4 in Kernel.ParallelCompiler.spawn_compilers/8
    
    ** (exit) shutdown: 1
        (elixir) lib/kernel/parallel_compiler.ex:202: Kernel.ParallelCompiler.handle_failure/5
~~~
每个方法的定义部分是一个三元素的元祖，第一个元素是名称，第二个是定义所在的行号，第三个是参数列表，每个参数自己是一个元祖。
由于我们劫持了def 所以报错也是情理之中。

你可能好奇宏定义的形式：defmacro def(definition, do: _content) ...  do: 在参数中不是特殊语法，他只是一个简单的参数匹配 
作为函数体传递的块，是一个关键字列表。

你可能也好奇是否我们已经影响到了关键字Kernel.def 宏。答案是没有。我们是创建了另一个宏，也叫def，定义在Tracer模块域中。在我们
的Test模块 我们告诉Elivir不要导入Kernel版的def，替而导入Tracer版的def。 简言之，原始kernel版的实现不受影响。

现在我们看看如果我们定义一个真正的函数给出这些信息，出乎意料的是相当容易。我们已经有传递给def的两个参数的信息了，所有我
们要做的就是继续传递他们。
~~~

    defmodule Tracer do
        defmacro def(definition , do: content) do
            quote do
                Kernel.def(unquote(definition)) do
                    unquote(content)
                end
            end
        end
    
    end
    
    defmodule Test do
        import Kernel, except: [def: 2]
        import Tracer, only:   [def: 2]
        def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
        def add_list(list),        do: Enum.reduce(list, 0, &(&1+&2))
    end
    
    Test.puts_sum_three(1,2,3)
    Test.add_list([5,6,7,8])
    
    iex(2)> c("use/tracer2.ex")
    use/tracer2.ex:1: warning: redefining module Tracer
    use/tracer2.ex:12: warning: redefining module Test
    6
    [Test, Tracer]
~~~
当我们运行这个，我们看到了6 ，来自puts_sum_three 的输出。

现在该添加一些追踪信息了

~~~

    defmodule Tracer do
        def dump_args(args) do
            args
            |> Enum.map(&inspect/1)
            |> Enum.join(", ")
        end
    
        def dump_defn(name, args ) do
            "#{name}(#{dump_args(args)})"
        end
    
        defmacro def(definition={name,_,args},do: content) do
            quote do
                Kernel.def(unquote(definition)) do
                    IO.puts "==> call: #{Tracer.dump_defn(unquote(name),unquote(args))}"
                    result = unquote(content)
                    IO.puts "<== result: #{result}"
                    result
                end
            end
        end
    end
    
    defmodule Test do
        import Kernel, except: [def: 2]
        import Tracer, only:   [def: 2]
        def puts_sum_three(a,b,c), do:  IO.inspect(a+b+c)
        def add_list(list), do: Enum.reduce(list, 0, &(&1 + &2))
    end
    
    Test.puts_sum_three(1,2,3)
    Test.add_list([5,6,7,7])
    
    iex(3)> c("use/tracer3.ex")
    use/tracer3.ex:1: warning: redefining module Tracer
    use/tracer3.ex:24: warning: redefining module Test
    ==> call: puts_sum_three(1, 2, 3)
    6
    <== result: 6
    ==> call: add_list([5, 6, 7, 7])
    <== result: 25
    [Test, Tracer]
    iex(4)>
    
~~~
现在让我们打包我们的Tracer模块，便于客户端只需要添加 use Tracer 到他们自己的模块中。 我们只需要实现__using__回调

~~~

    defmodule Tracer do
        def dump_args(args) do
            args |> Enum.map(&inspect/1) |> Enum.join(", ")
        end
    
        def dump_defn(name, args) do
            "#{name}(#{dump_args(args)})"
        end
    
        defmacro def(definition = {name,_, args} ,do: content ) do
            quote do
                Kernel.def(unquote(definition)) do
                    IO.puts "==> call: #{Tracer.dump_defn(unquote(name), unquote(args))}"
                    result = unquote(content)
                    IO.puts "<== result: #{result}"
                    result
                end
            end
        end
    
        defmacro __using__(_opts) do
            quote do
                import Kernel, except: [def: 2]
                import unquote(__MODULE__) , only: [def: 2]
            end
        end
    end
    
    defmodule Test do
        use Tracer
        def puts_sum_three(a,b,c), do: IO.inspect(a+b+c)
        def add_list(list), do: Enum.reduce(list, 0 , &(&1 + &2 ))
    end
    
    Test.puts_sum_three(1,2,3)
    Test.add_list([5,6,7,8 ])
    
    iex(4)> c("use/tracer4.ex")
    use/tracer4.ex:1: warning: redefining module Tracer
    use/tracer4.ex:29: warning: redefining module Test
    ==> call: puts_sum_three(1, 2, 3)
    6
    <== result: 6
    ==> call: add_list([5, 6, 7, 8])
    <== result: 26
    [Test, Tracer]
    iex(5)>
    
~~~

## Use use
Elixir 的行为很炫丽 --- 你可以很容易的在你写的模块中注入功能。他们并不只是对于库创建者有意义 -- 使用他们在你的代码中 来
减少重复工作和一些骨架工作

你有时需要扩展其他人写的模块 -- 你不能更改的代码 。 幸运的是 Elixir伴有protocals ！


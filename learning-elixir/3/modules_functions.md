模块和函数      ---------- 创建函式构建块
=================

## Modules
如果你学过Python 模块不是新概念了。
它们定义了一些函数和函数来自的基本名空间，这避免了名称冲突 并全局性的引入了某种层面的可插拔和重用性。
Elixir中的模块也相似 遵从这种通用概念。

Elixir中的模块，定义了一些共有和私有的函数集 这些函数可被外部也可被内部使用。
语法：
>  defmodule <name> do block end 

最简单的模块定义
>   defmodule Foobar do end

~~~iex

    iex(3)> defmodule Foo do end
    {:module, Foo,
     <<70, 79, 82, 49, 0, 0, 3, 184, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 94, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     nil}
~~~
这是VM的内部对模块的表示，一个元祖，

- 第一个元素是一个atom原子:module;
- 第二个 模块的名字
- 第三个 定义模块的二进制
- 第四个是个nil 因为模块并没有导出（暴露）任何公共的函数。

有意思的模块 会定义一些函数的。

## 匿名函数

匿名函数很像常规函数 除了它没有绑定到一个标识符。

两种语法形式
-  fn()  -> block end
-   &(block)             短形式

>
    iex(5)> (fn x,y,z -> x+y * z end).(2,6,8)
    50  
    iex(6)> (&(&1+&2*&3)).(2,6,8)
    50

短形式更注重简洁和函数参数顺序，如果匿名函数比较长 ，还是选择长语法形式。

## 模式匹配

像Elixir中的其他事情，匿名函数支持模式匹配！
~~~

    iex(7)> area = fn {:circle, r} ->
    ...(7)> 3.14159 * r * r
    ...(7)> {:rect, w, h}->
    ...(7)> w * h
    ...(7)> end
    #Function<6.54118792/1 in :erl_eval.expr/5>
~~~
我们定义了一个area函数 该函数可以计算远的面积或者长方形面积 通过匹配元祖（在形状类型上 通过原子 第一个参数）
~~~iex

    iex(8)> area.({:circle, 5})
    78.53975
    iex(9)> area.({:rect, 5, 5})
    25
    iex(10)> area.({:circle, 5, 5})
    ** (FunctionClauseError) no function clause matching in :erl_eval."-inside-an-interpreted-fun-"/1
    iex(10)> area.({:rect,  5})
    ** (FunctionClauseError) no function clause matching in :erl_eval."-inside-an-interpreted-fun-"/1
~~~   

## 命名函数

命名函数，不像你们函数，需要一个模块定义，就是要定义一个命名函数我们必须定义一个模块（蜗牛要有壳的）
~~~
    
    defmodule MyMath do
        def square(x) do
            x * x
        end
    end
~~~
导入文件
~~~

    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes>iex
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> import_file("mymath.exs")
    {:module, MyMath,
     <<70, 79, 82, 49, 0, 0, 4, 164, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 147, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:square, 1}}
    iex(2)> MyMath.square 4
    16
~~~
看到模块内存存储中 导出了一个公共函数 :square

跟其他语言不一样，为了在当前模块中调用另一个不同名空间中的函数（当前模块是IEx），我们需要冠以模块名前缀来调用函数。

## 私有函数

内部的 不应被模块外部直接访问的函数

使用 defp 构造

举个简单例子，我们可以定义个函数在模块中 之后再定义一个私有函数 **真正的** 执行命名函数的工作：
~~~
    
    defmodule MyMath do
        def square(x) do
            do_square(x)
        end
        
        # 私有函数
        defp do_square(x), do: x * x
    end
~~~
d导入此函数到iex：
~~~iex

    iex(3)> import_file("mymath2.exs")
    iex:1: warning: redefining module MyMath
    {:module, MyMath,
     <<70, 79, 82, 49, 0, 0, 4, 236, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 147, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:do_square, 1}}
~~~
看到元祖中出现的是:do_square 而不是 :square? 是因为函数不够有趣（啥情况这是  有趣了就出现了？）
但并不意味着我们要使用此模块需要知道私有函数的名字 仍旧是公共函数
>   MyMath.square 2

私有函数之上在 域（scoping） 上跟普通函数不一样 其余都一样（模式匹配等）

## 调用函数

~~~iex

    iex(4)> MyMath.square(4)
    16
    iex(5)> MyMath.square 4
    16
~~~
带括号和不带括号的结果一样

语法很大部分借自Ruby

选择这两种的一个只是风格问题  不管选择哪种 最好保持一致性（不要 忽而要括号 忽而不用括号 使人迷惑）

有些情况下 必须使用括号的，比如参数的显式绑定 或者调用你们函数

## 什么时候用 **.**
.() 语法来调用函数

什么时候用 什么时候不用？
调用匿名函数或者以&{foo}/{arity}捕捉的函数处理 时  否则使用使用常规语法（没有 **.**的）

比如我们每次定义匿名函数时 我们使用 **.()** 语法
~~~
    
    iex> f = fn x -> x * x end
    ...
    iex> f.(2)
    4
~~~
然而当我们定义的函数是模块的一部分时，我们使用常规语法
~~~

    defmodule Foo do
        def f(x), do: x * x
    end
    
    iex> Foo.f(2)
    4
~~~

## Grabbing functions
Elixir 支持把函数作为参数传递 ，即 Elixir的函数是类型心痛中的一等公民 ，但是如何传递已经存在的函数？
我们使用 **&** 操作符 或者函数捕获操作符 (&XXX.xx/arity)。
~~~
    
    import_file("mymath.exs")
    ...
    Enum.map([1,2,3], &MyMath.square/1)
    [1,4,9]
~~~

## 当模式匹配不够用时

模式匹配常用在assignment（reading binding 读绑定）表达式和函数中
当简单的类型分解模式（type decomposition pattern）不够用时，我们可以用**guards** 来做另一层匹配

Guards 只是简单的 boolean表达式 我们可以添加到我们的函数定义上来做模式匹配（定义更多约束 或者 规范）
~~~iex

    defmodule MyMath do
        def sqrt(x) when x >=0, do: () # implement sqrt
    end
~~~
guard表达式 允许的字句：

-  所有的比较操作符（ == , !=, ===, !==, >,<,<=,>= ）
-  布尔操作符（and，or） 和取反操作符(not, !)    
-  <> 和 ++ 只要左侧是一个字面量
-   in 操作符
-  所有下面的类型检测函数：
    - is_atom/1
    - is_binary/1
    - is_bitstring/1
    - is_boolean/1
    - is_float/1
    - is_function/1 和 is_function/2
    - is_integer/1
    - is_list/1
    - is_map/1
    - is_nil/1
    - is_number/1
    - is_pid/1
    - is_port/1
    - is_reference/1
    - is_tuple/1
    
    加这些函数
    - abs(number)
    - bit_size(bitstring)
    - div(integer, integer)
    - elem(tuple, n)
    - hd(list)
    - map_size(map)
    - node()
    - node(pid | ref | port)
    - rem(integer, integer)
    - round(number)
    - self()
    - tl(list)
    - trunc(number)
    - tuple_size(tuple)
此外用户也可以定义其自身的guards 经常以 is_. 开始。
        
## 日常会碰到的函数式问题

当见过 模块，函数，guards 和基本类型后 以及基本的模式匹配 ，我们就具备解决问题的基础了！

## 迭代 VS 递归

在函数式语言中经常使用递归来代替迭代 ，迭代 如天然的需要边缘效应（side-effects），如 使用一个for循环，许多语言需要循环修改
某些状态（经常是一个整数）来追踪循环执行的地方

函数式语言，对应地倾向使用递归策略

有人可能会争议，迭代没有递归的一些问题，显著地，迭代可以是无限地，然而递归受限于栈！当解决迭代和解决递归使用特定算法所需
空间和时间复杂度不一样。

递归有些好处的，简单地，描述计算使用递归更简单，当定义递归函数，我们的描述更基础，甚至是数学 概念模型，而迭代隐藏了概念

为了避免栈空间耗尽 ，Elixir或者Erlang使用了 **tail recursion**
尾部递归使用了运行时修改精心设计的栈的方式 通过合并尾部帧

~~~

    defmodule Fibonacci do
        def seq(0), do: 0
        def seq(1), do: 1
        def seq(n) when n > 1, do: seq(n-1) + seq(n-2)
    end
~~~
这里用尾部递归也没多大用？ 
想问题的方式需要变，不要用斐波那契数列的定义，让我们反转它，从后往前用！
不要从 n 开始 让我们从1(或者2 )开始 并累加起来

~~~

    defmodule Fibonacci do
        def seq(0), do: 0
        def seq(1), do: 1
        def seq(n) when n>1 do
            compute_seq(n, 1, [0, 1])
        end
        
        defp compute_seq(n, i , acc) when n == i, do: Enum.at(acc,
        length(acc) - 1)
        defp compute_seq(n, i , acc) do
            len = length(acc)
            compute_seq(m, i+1, acc ++ [Enum.at(acc, len-1) + Enum.at(acc, len-2)])
        end
    end
~~
不是从序列的顶部计算，我们从序列底部开始 构造结果

使用time看看时间：
> time elixir fibonacci_1.exs
> time elixir fibonacci_2.exs

### 性能考虑
当使用尾部递归时 必须处理的性能考量，

精心设计 意即 运行时是**actually capable** 执行了尾部调用优化 如果递归构造不当就失去了尾部调用优化的好处。
比如 fact(n-1) * n 和 n * fact(n-1)

## 反转
~~~
    
    defmodule Reverse do
        def reverse([]), do: []
        def reverse([h|t]), do:reverse(t) ++ [h]
    end
~~~
首先为我们的基础情形定义了一个模式，空列表 并简单地返回那个空列表。我们也定义了一个模式 它允许我们分解列表的首部和尾部。
模式的体 之后用来构建反转 通过添加列表的首部到 尾部反转的递归调用上。
~~~

    iex(1)> import_file "reverse.exs"
    ...
    iex(2)> Reverse.reverse [1, 2, 3, 4, 5]
    [5, 4, 3, 2, 1]
    iex(3)> Reverse.reverse 'Hello, World!'
    '!dlroW ,olleH'
~~~
注意单引号的字符串 是简单的字符的列表哦！

## 排序 Sorting
另一个模式匹配的例子是实现排序算法，快速排序
~~~

    defmodule Sort do
        def quicksort([]), do: []
        def quicksort([h|t]) do
            lower = Enum.filter(t, &(&1 <= h))
            upper = Enum.filter(t, &(&1 >h))
            quicksort(lower) ++ [h] ++ quicksort(upper)
        end
    end
~~~
Enum.filter/2 函数接受一个集合和一个匿名函数


## Mix   the ladle of Elixir

总是和一个定义于脚本文件中的简单模块交互或者交互提示下工作是不够的， 最终我们需要的不是脚本。
我们需要的是源码树 封装我们的项目代码（需要的是正规军 不是游击队）。
更甚 ，我们需要一个工具来创建源码树，构建源码，测试，管理依赖，或者其他一系列任务，这个工具在Elixir中就是
**mix**

它创建项目，编译源码，运行测试，打包项目到可分发单元，甚至运行我们运行我们的项目，导入必要的文件到iex中。
 
>   F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes>mix help
    mix                   # Runs the default task (current: "mix run")
    mix app.start         # Starts all registered apps
    mix archive           # Lists all archives
    mix archive.build     # Archives this project into a .ez file
    mix archive.install   # Installs an archive locally
    mix archive.uninstall # Uninstalls archives
    mix clean             # Deletes generated application files
    mix cmd               # Executes the given command
    mix compile           # Compiles source files
    mix deps              # Lists dependencies and their status
    mix deps.clean        # Deletes the given dependencies' files
    mix deps.compile      # Compiles dependencies
    mix deps.get          # Gets all out of date dependencies
    mix deps.unlock       # Unlocks the given dependencies
    mix deps.update       # Updates the given dependencies
    mix do                # Executes the tasks separated by comma
    mix escript.build     # Builds an escript for the project
    mix help              # Prints help information for tasks
    mix hex               # Prints Hex help information
    mix hex.build         # Builds a new package version locally
    mix hex.config        # Reads or updates Hex config
    mix hex.docs          # Publishes docs for package
    mix hex.info          # Prints Hex information
    mix hex.key           # Hex API key tasks
    mix hex.outdated      # Shows outdated Hex deps for the current project
    mix hex.owner         # Hex package ownership tasks
    mix hex.publish       # Publishes a new package version
    mix hex.registry      # Hex registry tasks
    mix hex.search        # Searches for package names
    mix hex.user          # Hex user tasks
    mix loadconfig        # Loads and persists the given configuration
    mix local             # Lists local tasks
    mix local.hex         # Installs Hex locally
    mix local.public_keys # Manages public keys
    mix local.rebar       # Installs rebar locally
    mix new               # Creates a new Elixir project
    mix phoenix.new       # Create a new Phoenix v1.0.4 application
    mix profile.fprof     # Profiles the given file or expression with fprof
    mix run               # Runs the given file or expression
    mix test              # Runs a project's tests
    iex -S mix            # Starts IEx and run the default task
    
和其他优秀命令一样 mix 随来了一个help命令 给我们了一个列表 示出我们能够干什么
    
我们可以使用mix help 来获取一个更具体的任务
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes>mix help new
    # mix new
    
    Creates a new Elixir project.
    It expects the path of the project as argument.
    
        mix new PATH [--sup] [--module MODULE] [--app APP] [--umbrella]
    
    A project at the given PATH  will be created. The
    application name and module name will be retrieved
    from the path, unless `--module` or `--app` is given.
    
    A `--sup` option can be given to generate an OTP application
    skeleton including a supervision tree. Normally an app is
    generated without a supervisor and without the app callback.
    
    An `--umbrella` option can be given to generate an
    umbrella project.
    
    An `--app` option can be given in order to
    name the OTP application for the project.
    
    A `--module` option can be given in order
    to name the modules in the generated code skeleton.
    
    ## Examples
    
        mix new hello_world
    
    Is equivalent to:
    
        mix new hello_world --module HelloWorld
    
    To generate an app with supervisor and application callback:
    
        mix new hello_world --sup
    
    
    Location: c:/Program Files (x86)/Elixir/lib/mix/ebin
        
创建项目
>   mix new hello_world

等价
>   mix new hello_world --module HelloWorld

生成一个又supervisor和应用回调的app
> mix new hello_world --sup


## Elixir 项目的结构
~~~shell

    $ mix new hell_world
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/hell_world.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/hell_world_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd hell_world
        mix test
    
    Run "mix help" for more commands.
~~~

- mix.exs
此文件描述了我们的项目，实际是个Elixir代码并定义了一个模块，被mix用来编译，测试依赖，打包项目 运行项目。
改模块定义了一些函数返回项目的信息。

- .gitignore
   git 版本管理中需要忽略的文件列表

- config
   配置目录 包含我们项目的配置设定，这是全局的 在项目运行期可以引用的高级别的选项

- README.md
  mackdown语法的文件 简单的描述我们的项目 以及怎样构建和安装项目 怎样使用它 什么地方用 等信息

- lib
  此目录，同其他语言不一样，这个才是真正的Elixir源码所在地，mix构建项目时会在这里查找代码的

- test
  用来测试的
  
## 编译一个项目
~~~

    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes\hell_world>mix compile
    Compiled lib/hell_world.ex
    Generated hell_world app
~~~
Elixir找到我们的lib/hello_world.ex 模块， 编译它 之后生成我们的app 。
目前需不要关系Erlang的application 当只需要知道他的存在。

编译后_build 目录我们项目的.beam 文件

## 测试项目
> $ mix test

## 交互式运行
最后如果我们想运行我们的代码，我们需啊哟设定一个iex的特殊选项来编译我们的项目。如果必须，我们可以包含它到交互会话中：
~~~
    
    iex -S mix
    Eshell V7.0 
    iex(1)> HellWorld.hello
    Hello , World!
    :ok
~~~
因为原先生成的骨架项目中的模块是空内容，所以添加一点内容：

~~~elixir

    defmodule HellWorld do
    
        def hello(name \\ "World") do
            IO.puts "Hello , #{name}!"
        end
    end
~~~
可以看到 通过这种方法 我们可以跟项目中的模块交互了

## Files 文件们

如我们所见到的，Elixir有两种类型的文件  .ex 和 。exs
区别是什么？

其实是惯例和意向 两种文件都编译为字节码 由VM来运行。但是文件后缀通知编译器和VM 以及我们自己 文件有特定目的。

.ex 文件致力于项目文件的源码，意图是作为项目或者应用的部件来运行，
相较于.exs 文件 ，他们的意图是脚本，配置 或者测试 ，这些文件同.ex一样被编译 但结果字节码是短暂的并在文件目标完成后被丢弃。

## Mix and beyond 超越Mix

## 构建函数式项目
### Flatten项目
~~~ shell
    
    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes>mix new flatten
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/flatten.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/flatten_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd flatten
        mix test
    
    Run "mix help" for more commands.
~~~
修改主模块
~~~

    defmodule Flatten do
    
        def flatten([]), do: []
        def flatten([h|t]) when is_list(h), do: h ++ flatten(t)
    end
~~~
在iex下交互运行

~~~
         
    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes>cd flatten
    
    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes\flatten>iex -s mix
    Eshell V7.0  (abort with ^G)
    -s : Unknown option
    No file named mix
    
    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes\flatten>iex -S mix
    Eshell V7.0  (abort with ^G)
    Compiled lib/flatten.ex
    Generated flatten app
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> Flatten.flatten [[1,2],[3],[4,5]]
    [1, 2, 3, 4, 5]
~~~
写个测试来确保如预期那样工作
## 测试的小介绍
测试是基本的，许多语言现在都内置其作为语言的一部分

在Elixir中写测试，除了语法 和写函数无异 。
我们定义一个模块和一些测试（函数），并断定一些我们期望的结果。

mix已创建了test目录，并创建了测试骨架（为主模块）
打开 test/flatten_test.exs
~~~
    
    defmodule FlattenTest do
      use ExUnit.Case
      doctest Flatten
    
      test "the truth" do
        assert 1 + 1 == 2
      end
    end
~~~
让我们故意弄错些东西 看看结果
>    assert 1 + 1 == 5 # 故意造成一个 false 

然后运行
~~~

    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes\flatten>mix test
    Compiled lib/flatten.ex
    Generated flatten app
    
    
      1) test the truth (FlattenTest)
         test/flatten_test.exs:5
         Assertion with == failed
         code: 1 + 1 == 5
         lhs:  2
         rhs:  5
         stacktrace:
           test/flatten_test.exs:6
    
    
    
    Finished in 0.1 seconds (0.09s on load, 0.03s on tests)
    1 test, 1 failure
    
    Randomized with seed 110000
~~~
可以看到导致错误失败的信息，我们可以藉此找到是什么导致了测试失败。

退回修改，并写我们自己的测试:
~~~

    test "the truth" do
        assert 1 + 1 ==  2
      end
    
      test "return flat list when given nested lists" do
        expected = [1 ,2 ,3 ,4 ,5]
        actual = Flatten.flatten [[1,2],[3],[4,5]]
        assert actual == expected
      end
~~~

保存，并继续运行测试：
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes\flatten>mix test
    ..
    
    Finished in 0.07 seconds (0.07s on load, 0.00s on tests)
    2 tests, 0 failures
    
    Randomized with seed 600000

看到测试通过了！
但代码看上去有点怪味 在写个测试
~~~
    
     test "resturn flat list when no nesting" do
        expected = [1,2,3,4,5]
        actual = Flatten.flatten expected
        assert actual == expected
      end
~~~
运行测试
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes\flatten>mix test
    
    
      1) test resturn flat list when no nesting (FlattenTest)
         test/flatten_test.exs:15
         ** (FunctionClauseError) no function clause matching in Flatten.flatten/1
         stacktrace:
           (flatten) lib/flatten.ex:3: Flatten.flatten([1, 2, 3, 4, 5])
           test/flatten_test.exs:17
    
    ..
    
    Finished in 0.06 seconds (0.06s on load, 0.00s on tests)
    3 tests, 1 failure
    
    Randomized with seed 17000
 
什么导致了测试失败。

源于我们假设列表的头是另一个list列表，但是我们说的是函数应该可以处理人员深度的嵌套，0嵌套也是符合的 所以需要另一个模式

修改我们的Flatten模块
~~~

    defmodule Flatten do
        # 注意模式匹配的顺序哟！
        def flatten([]), do: []
        def flatten([h|t]) when is_list(h), do: h ++ flatten(t)
        def flatten([h|t]), do: [h] ++ flatten(t)
    end
~~~
然后再次运行测试
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes\flatten>mix test
    Compiled lib/flatten.ex
    Generated flatten app
    ...
    
    Finished in 0.06 seconds (0.06s on load, 0.00s on tests)
    3 tests, 0 failures
    
    Randomized with seed 684000
    
上面的操作过程和常规的TDD或者测试驱动策略没多大区别
    
## 更多关于模块的

模块是我们构建块的封装单元，他们针对函数block来说是顶级block。但偶尔 ，我们想获取我们模块的数据和元数据在我们的构建块上。
我们可能想文档化我们的代码，想跟随我们的人可以读到这些注释和文档，更好的 希望有一个好用的工具来构建我们代码的富文档

或者不是文档化 我们想要通过特定的属性标记（tag）我们的模块和函数。

为了支持这些目标 ，Elixir给了我们这样的能力来获取模块属性，可以作为开发者或者用户，或者用于VM。相似地 我们可以像常量来使用
属性。

在Elixir中属性被定义为： @name 的形式。比如添加@vsn属性来标注一个模块：
~~~
    
    defmodule MyModule do
        @vsn 1
    end
~~~
来看看两个最常用的属性  --  @moduledoc 和 @doc

我们可以定义一个Math模块 使用@moduledoc 和@doc 属性：
~~~
        
    defmodule Math do
       @moduledoc """
              Provides math-related functions
              """
    
        @doc"""
        Calculate factorial of a number .
    
        ## Example
    
            iex> Math.factorial(5)
            120
        """
        def factorial(n), do: do_factorial(n)
    
        defp do_factorial(0), do: 1
        defp do_factorial(n), do: n * do_factorial(n-1)
    
        @doc """
        Compute the binomial coefficient of `n` 和 `k`
    
        ## Example
            iex> Math.binomial(4, 2)
            6
        """
        def binomial(n,k), do: div(factorial(n), factorial(k)* factorial(n-k))
    end
~~~
保存这个文件并编译
>   elixir math.ex

都好着，也没看到任何输出和退出码

接下来打开iex 获取我们的Math模块的文档
~~~

    F:\Elixir-workspace\elixer-coder\learning-elixir\3\codes>iex
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> h Math
    Could not load module Math, got: nofile
    iex(2)> c "math.ex"
    [Math]
    iex(3)> h Math
    * Math
    
    Provides math-related functions
    
    iex(4)> h Math.factorial
    * def factorial(n)
    
    Calculate factorial of a number .
    
    ## Example
    
        iex> Math.factorial(5)
        120

~~~

就是 我们可以使用 h/1 函数在iex中在我们的模块或者函数上拉取文档

## Testing with comments
@moduledoc和@doc属性 另一个比较酷的特性 所谓的 **doctesting**
意即 在我们评论中的行 看起来像 iex 会话的可以被用于测试 

回到Flatten项目
为我们的函数添加@doc 评论
添加的评论看起来跟在iex 会话中 手动测试函数 相似
~~~

    defmodule Flatten do
        # 注意模式匹配的顺序哟！
    
        @doc """
        Flatten an arbitrarily nested lists
    
        ## Examples
    
            iex> Flatten.flatten [[1,2] ,[3] ,[4,5]]
            [1,2,3,4,5]
            iex> Flatten.flatten [1,2,3,4,5]
            [1,2,3,4,5]
        """
        def flatten([]), do: []
        def flatten([h|t]) when is_list(h), do: h ++ flatten(t)
        def flatten([h|t]), do: [h] ++ flatten(t)
    end

~~~
接下来 打开flatten_test.exs 文件 在顶部添加
> doctest(Flatten)

在@doc属性中的测试会被合并到一个独立的测试 当使用这种方式测试时。








    
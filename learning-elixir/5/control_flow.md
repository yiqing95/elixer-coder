控制流 --  偶尔才需要使用分支
==================

控制语句，也称之为分支语句

### if and unless

Elixir 同其他语言一样，有自己的if 和 else 版本。Elixir 也有if的逻辑反： **unless**
然而这些结构在Elixir中是非常简单的 只能测试 单个条件；
~~~

    x = 42
    if x>0 do
      IO.puts   x * -1
    
    end
    
    IO.puts x
~~~
>
    iex(4)> if 1>2 do
    ...(4)> "this is won't be retured"
    ...(4)> end
    nil
    iex(5)>
    
记着 任何东西都是表达式，即使是分支语句。即，即使我们基于某些条件分叉了执行路径，分支的最后表达式会被隐式地返回。
比如 ，如果我们链接了一系列的表达式在一起，最后一个表达式会被返回。   
>
    iex(5)> if true do
    ...(5)> x = 42
    ...(5)> y = x + 8
    ...(5)> z = x + y - 42
    ...(5)> z
    ...(5)> end
    50
    
即使使用else 表达式也返回分叉路径的最后值
>
    iex(6)> if false do
    ...(6)> "nope"
    ...(6)> else
    ...(6)> "I will be returned"
    ...(6)> end
    "I will be returned"
    
因为表达式必须返回值，我们甚至可以使用模式匹配在返回的表达式上：
>
    iex(7)> 42 = if true do
    ...(7)> 42
    ...(7)> end
    42

**unless** 很像if ，实际上，被实现为if的反转
>
    iex(8)> nil = unless true do 42 end
    nil
    iex(9)> 42 = unless false do 42 end
    42

此外，和if类似，unless 也有else 块
>
    iex(10)> "true" = unless true do 42 else "true" end
    "true"
    iex(11)>

实际，使用unless 等价于 if not condition ...:
>
    iex(12)> "false" = if not false do "false" else "true" end
    "false"
    
## the new else if
因为我们不能链式使用： if else if 表达式。
cond ：
~~~
    
    x = 42
    if x>0 do
      IO.puts   x * -1
    
    end
    
    IO.puts x
    
    cond do
    2 + 2 == 5 -> "For big values of 2"
    2 + 2 == 3 -> "For poorly sided squares ..."
    1 + 1 == 2 -> "Math seems to work."
    end

    iex(13)> import_file "if.exs"
    -42
    42
    "Math seems to work."
~~~
这看起来很像 基于C 语言的 switch 语句。
然后，没有同switch语句中的“fall through”行为 

顺序问题：
>
    cond do
    true -> "Always"
    true -> "Never"
    false -> "Similarly never"
    end
    "Always"
        
>
    x = 7
    y = 2
    cond do
    x + y > 8 ->
    y = x - y * div(x, y)
    x = y - x
    x - y < 0 ->
    x = y - x * div(y, x)
    y = x - y
    true -> "Else"
    end

通过 -> 把表达式归组。我们可以使用任意多的表达式只要适于阅读。 注意上面的 末尾的true ！    
>
    iex(2)> cond do
    ...(2)> false  -> "This is never returned"
    ...(2)> end
    ** (CondClauseError) no cond clause evaluated to a true value

因此共同实践就是添加true 作为 else 表达式。

更深层次 因为任何事情都是一个表达式，我们可以绑定 cond的结果表达式给一个名字：
>
    iex(2)> result = cond do
    ...(2)> 2 + 2 == 5 -> "For large values of 2"
    ...(2)> 2 * 2 == 3 -> "For oddly shaped squares"
    ...(2)> 1 + 1 == 2 -> "Because math works"
    ...(2)> end
    "Because math works"
    iex(3)> IO.puts result
    Because math works
    :ok
    
一样 ，我们也可以在cond结果上使用模式匹配 
    
## Elixir case 表达式

case 通 cond 表达式很像 除了其行为更像模式匹配 。

我们使用case 更加本地化地 测试不同代码块的分支 基于单独的一个值 ，此点 其更像 C 或者 Java的 switch语句。
>
    iex(4)> mylist = [1, 2, 3, 4]
    [1, 2, 3, 4]
    iex(5)> case mylist do
    ...(5)> [a, 2, c, d] ->
    ...(5)> "Second element is 2"
    ...(5)> a + c * d - 2
    ...(5)> _ -> "Second element was _not_ 2"
    ...(5)> end
    iex: warning: code block starting at line contains unused literal "Second element is 2" (remove the literal or assign it to _ to avoid warnings)
    11

case 更接近于模式匹配 ，我们使用更多的语法和语义来自模式匹配而不是条件式 ，
我们使用 _ 下划线 用于失配情况 。 这给我们了在case语句中 像 else 字句的行为 。

另一个case例子：
>
    iex(6)> x = 1
    1
    iex(7)> case 10 do
    ...(7)> ^x -> "Won't match"
    ...(7)> end
    ** (CaseClauseError) no case clause matching: 10

## 使用branch 的例子
~~~

    defmodule FizzBuzz do
      @moduledoc false
    
      def print() do
        1..100 |> Enum.map( fn(x) ->
          cond do
            rem(x, 15) == 0 -> "FizzBuzz"
            rem(x, 3) == 0 -> "Fizz"
            rem(x, 5) == 0 -> "Buzz"
            true -> x
          end
        end) |> Enum.each(fn(x) -> IO.puts(x) end)
      end
    end
~~~
为什么没有用Enum.map/2  Enum.map/2和Enum.each/2的关键区别是其目的和结果。
Enum.map/2 返回流中的的每个元素结果。而Enum.each/2 只返回:ok 即结果被丢弃了 这很适合打印每个元素
~~~
        
    iex(7)> import_file "fizz_buzz.ex"
    {:module, FizzBuzz,
     <<70, 79, 82, 49, 0, 0, 7, 40, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 130, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:print, 0}}
    iex(8)> FizzBuzz.print
    1
    2
    Fizz
    4
    Buzz
    Fizz
    7
    8
    Fizz
    Buzz
    11
    Fizz
    13
    14
    FizzBuzz
    16
    17
    Fizz
    19
    Buzz
    Fizz
    22
    23
    Fizz
    Buzz
    26
    Fizz
    28
    29
    FizzBuzz
    31
    32
    Fizz
    34
    Buzz
    Fizz
    37
    38
    Fizz
    Buzz
    41
    Fizz
    43
    44
    FizzBuzz
    46
    47
    Fizz
    49
    Buzz
    Fizz
    52
    53
    Fizz
    Buzz
    56
    Fizz
    58
    59
    FizzBuzz
    61
    62
    Fizz
    64
    Buzz
    Fizz
    67
    68
    Fizz
    Buzz
    71
    Fizz
    73
    74
    FizzBuzz
    76
    77
    Fizz
    79
    Buzz
    Fizz
    82
    83
    Fizz
    Buzz
    86
    Fizz
    88
    89
    FizzBuzz
    91
    92
    Fizz
    94
    Buzz
    Fizz
    97
    98
    Fizz
    Buzz
    :ok
~~~

## Mergesort 合并排序

快速排序最差情况是 O(n2) 而 合并排序最差情况是 O(n log(n)).

先创建项目
>
    
    F:\Elixir-workspace\elixer-coder\learning-elixir\5\codes>mix new mergesort
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/mergesort.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/mergesort_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd mergesort
        mix test
    
    Run "mix help" for more commands.
    
## 写测试

测试驱动风格中，我们需要先创建我们的测试，如果愿意也可以最后写测试。
~~~

       test "test returns [] when empty " do
           assert [] == Mergesort.sort([])
         end
   
     test "test return sorted list when given reserverd list " do
       assert [1,2,3,4] == Mergesort.sort([4,3,2,1])
     end
   
     test "merge returns [] when given empty lists " do
       assert [] == Mergesort.merge([], [])
     end
   
     test "merge returns side when other is empty " do
       l = [1,2,4,5]
       ^l = Mergesort.merge(l,[])
       ^l = Mergesort.merge([], l)
     end
   
     test "merge returns merged list" do
       left = [1,3,5,7]
       right = [2,4,6,8]
       assert [1,2,3,4,5,6,7,8] == Mergesort.merge(left, right)
     end
~~~

## implement the sort 实现排序

sort/1 函数自己很容易，简单地是一个递归函数 返回每个分片的合并结果。

打开 lib/mergesort.ex 文件
~~~

    defmodule Mergesort do
    
         def sort(l) do
               cond do
                    l == [] -> []
                    length(l) <= 1  -> l
                    true ->
                        middle = div(length(l), 2)
                        left = Enum.slice(l, 0, middle)
                        right = Enum.slice(l, middle, length(l) - length(left))
                        left = sort(left)
                        right = sort(right)
                        merge(left, right)
                end
          end
    end
~~~
如果列表时空的 ，返回空列表，如果列表有一个或者零个元素，返回给定列表。
最后如果列表有一个或者多于一个元素 ，最后一种情况，我们找到列表的中部，分割列表为左右两个 ，递归地mergesort每个部分 ，
最终合并结果。

接下来实现merge/2 函数：
~~~

    def merge(left, right) do
            cond do
                left == []   -> right
                right == []  -> left
                hd(left) <= hd(right)  -> [hd(left)] ++ merge(tl(left) , right)
                true -> [hd(right)] ++ merge(left, tl(right))
            end
        end
~~~

这里定义了三个模式，第一个用于第一个列表是空的 ，第二个用于第二个列表是空的，最后 最后一个模式实际做的merging合并。

对于最后一个模式，我们分离出来额每个列表的首部和尾部用于比较。在merge函数体内，测试是否第一个列表的首部小于或者等于第二个
列表的首部值 ，如果是，我们就创建一个新的列表 把第一个列表的首部放在首位 ，并 在第一个列表的尾部和第二个列表 上递归调用合并。
并且如果第二个列表的首部更小，我们创建一个新列表 使用第二个列表的首部，做相同的事情 （算法 质上是对称的）
至此运行测试
~~~
    
    F:\Elixir-workspace\elixer-coder\learning-elixir\5\codes\mergesort>mix test
    
    
      1) test test return sorted list when given reserverd list  (MergesortTest)
         test/mergesort_test.exs:13
         ** (ArgumentError) argument error
         stacktrace:
           (mergesort) lib/mergesort.ex:6: Mergesort.sort/1
           test/mergesort_test.exs:14
    
    .....
    
    Finished in 0.2 seconds (0.2s on load, 0.04s on tests)
    6 tests, 1 failure
    
    Randomized with seed 773000
~~~
看到有错误 最后发现源码中 **l** 和 **1** 拼写错误导致！
改正后重跑测试:
~~~

    F:\Elixir-workspace\elixer-coder\learning-elixir\5\codes\mergesort>mix test
    Compiled lib/mergesort.ex
    Generated mergesort app
    ......
    
    Finished in 0.06 seconds (0.06s on load, 0.00s on tests)
    6 tests, 0 failures
    
    Randomized with seed 104000

~~~

加载iex 来自定义测试数据
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\5\codes\mergesort>iex -S mix
    Eshell V7.0  (abort with ^G)
    Compiled lib/mergesort.ex
    Generated mergesort app
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> list = Stream.repeatedly( fn() -> :random.uniform(20) end) |>
    ...(1)> Enum.take(10)
    [9, 15, 19, 11, 7, 12, 19, 14, 10, 12]
    iex(2)> Mergesort.sort(list)
    [7, 9, 10, 11, 12, 12, 14, 15, 19, 19]
    iex(3)>


我们使用Stream.repeatedly/1 流 到Enum.take/2 来创建一个随机数列表。Stream.repeatedly/1 期望一个无参函数 所以用匿名函数来
包裹:random.uniform/1 函数。【:random.uniform/1 函数 是一个Erlang函数 可用来生成一个随机数在区间(0,N] 间 起于0 不包括N 】

可用多测试几个 用不同的数据 。确保sort函数正确运行。

## Exception handling 异常处理

你可能熟悉其他语言中的异常处理，当你在Elixir中你可能用以前的思维来想异常，但是 在Elixie这样的函数式编程中，我们不要忘却
过去所学。

Elixir 提供了基本的设施用来触发和捕获异常。

首先最红要的是 ： 异常在Elixir中  **不是** 控制流或者分支语句！
异常是严格意义上的异常行为，即 绝对不应该发生的事情发生了 ，一些异常的例子包括 数据库服务器宕机，名称服务失败，或者打开确定
位置的配置文件（不存在?） 然而 无法打开用户给定名称的文件不是一个异常（这种问题完全可以通过我们程序员避免发生）

系统 编程的假设 过早失败 还是经常失败（fail early 还是 fail often）

## Raising Exceptions 触发异常

在Elixir中触发异常 我们使用raise/1 和 raise/2 函数。
第一种 简单的指定一个异常字符串
>
    iex(3)> raise "Failing"
    ** (RuntimeError) Failing

第二种形式允许我们随异常消息一起指定异常类型
>
    iex(3)> raise RuntimeError , "Failing"
    ** (RuntimeError) Failing

raise 的第二个函数更有用 可以看看raise的文档以获取更多信息( 注意函数签名 跟常规的设计不一样 ， 在oo 程序中 如果类型是可
选参数 可能会作为第二个参数出现（即raise message XxxError ） 但Elixir中的模式匹配 好像不用管这种惯用法)

## Error , exit 和 throw

在Elixir中我们可以激发一个第二个error类型 使用error ，exit 和 throw。这些都可以被抓获和处理使用try-catch块。


### 处理异常
try-rescue 结构同其他语言中的try-catch块类似 但区别是try-rescue可以用来拯救发生的错误

try-rescue 块行为很像try-catch块，比如除零问题，我们可以局部处理它 而不是让他向上传递出去。
>
    iex(3)> try do
    ...(3)> 1 / 0
    ...(3)> rescue
    ...(3)> e in ArithmeticError -> e
    ...(3)> end
    %ArithmeticError{}

这里，我们挽救进程并打印错误结构而不用退出子进程。

### try-catch 块
try-catch块和try-rescue块类似，但有些细微差别，try-rescue块可以挽救错误并返回到正常流程，然而try-catch块通常执行一些额外的
代码而不是退出 。也就是 进程没有被保存，但在进程退出前一些额外的代码被执行了。
 
尽管有些许差别，try-catch块仍旧使用模式匹配的形式来操作。我们可以捕获 :exit, :throw 或者全部捕获。
例子：
>
    iex(4)> try do
    ...(4)> throw :fails
    ...(4)> catch
    ...(4)> :throw, value ->IO.puts :stderr, "Failure in above code: #{inspect value}"
    ...(4)> end
    :ok
    Failure in above code: :fails
    
相似地 我们可以捕获并退出：
>
    iex(5)> try do
    ...(5)> exit :oops
    ...(5)> catch
    ...(5)> :exit, code -> IO.puts :stderr ,"Exited: #{inspect code}"
    ...(5)> end
    Exited: :oops
    :ok
    
我们也可以使用Erlang的 error/1 函数 配合Elixir的try-catch:

>   
   iex(6)> try do
   ...(6)> :erlang.error "More oops"
   ...(6)> catch
   ...(6)> error -> IO.puts :stderr, "Error received: #{inspect error}"
   ...(6)> end
   ** (ErlangError) erlang error: "More oops"

在以上所有的情况，子进程都被关闭。我们没有看到这个在交互进会话中 因为失败的进程被立即重启了 。注意如果一个错误被抛出，
交互会话使用相同的数字重启

同其他语言类似，使用try-catch块，如果没有关联的catch对应特定的错误，raise会向上传递广播的。
>   
    iex(6)> try do
    ...(6)> throw "oops"
    ...(6)> catch
    ...(6)> :exit , code -> IO.puts :stderr , "Exit received #{inspect code}"
    ...(6)> end
    ** (throw) "oops"

因为在catch匹配中没有模式 对应 :throw ,value or _ , 抛出的值会传递catch到的 并被supervising进程捕获（顶级进程）。

## 使用异常

有些情况真正地需要出发异常；不然 我们应该允许错误传播到控制进程，比如，打开一个期待的应是可用的文件失败应该是一个异常
在这种情况下 应触发它。

## 打开文件
首先，让我们考虑如何执行文件操作 这些操作的结果是什么。

Elixir提供了File模块 可用来打开，读， 写 和关闭文件。

假设我们有一个文件在我们当前工作目录中:hello.txt 有下面的内容：
>   Hello, World!

我们可用打开并读取此文件 ：
>
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> {:ok, hello} = File.open "hello.txt"
    {:ok, #PID<0.59.0>}
    iex(2)> IO.read(hello, :all)
    "Hello, World!"
    iex(3)> :ok = File.close hello
    :ok

或者使用便捷方便函数 file.read/1 完成上吗所有的步骤。
>   iex(4)> {:ok, contents } = File.read "hello.txt"
    {:ok, "Hello, World!"}
    
所有的这些块都运行我们打开，读取整个文件内容，并关闭文件。喜欢选择哪个只是灵活性和控制问题。用IO.read/2 比之File.read/1
我们有更多的控制对文件如何读取 .然而 第一个列子需要更多的步骤，然而File.read/1 为我们做了这些步骤的抽象。

现在，当打开一个文件失败时会发生什么？或者，当打开一个不存在文件时发生什么？
>
    iex(6)> File.open "fake_file_path.txt"
    {:error, :enoent}
    
我们得到了一个元祖返回， 第一个元素是:error  第二个是:enoent .
很清楚 这不是一个好结果，如我们期待的 ;enoent 意味三个事情中的一个
- 路径没找到 
- 文件找不到
- 没有更多文件

为了找这些符号，我们偶尔需要查看Erlang的文档。

既然我们知道打开文件的基础，我们要看看我们如何使用结果来做不同事情。

我们可以使用case 表达式根据文件读取操作的成功或者失败：
>
    iex(7)> file_name = "fake_file_path.txt"
    "fake_file_path.txt"
    iex(8)> case File.read file_name do
    ...(8)> {:ok, contents} -> IO.puts contents
    ...(8)> {:error, reason} ->IO.puts :stderr, "Couldn't open file #{file_name} because: #{reason}"
    ...(8)> end
    Couldn't open file fake_file_path.txt because: enoent
    :ok
    
这里我们读取一个不存在的文件，如果文件存在，{:ok, contents} 元祖会被匹配， 并打印内容到:stdout(IO.puts/1 的默认设备)。
因为文件不存在，我们匹配到元祖：{:error, reason}, 结果是打印一个错误消息到 :stderr并提供原因。

【注意，这是个丑陋的消息对用户来说 除非用户使用了Erlang / Elixir  用户消息应该比这个更友好】

然而， 如果我们假设文件总是可用，我们可以重写前面的代码 使用raise/1 调用：
>
    iex(9)> case File.open "config_file" do
    ...(9)> {:ok, config_file} -> parse_config(config_file)
    ...(9)> {:error, reason} ->raise "Failed to open config file: #{reason}"
    ...(9)> end
    ** (CompileError) iex:10: undefined function parse_config/1
        (stdlib) lists.erl:1353: :lists.mapfoldl/3
        (stdlib) lists.erl:1353: :lists.mapfoldl/3
    iex(9)>

因为没定义parse_config 函数 所以报错了 那个只是占位而已 ，可以用空操作替换掉 看看下面的执行流    

此段代码和前面基本类似只是打开文件失败时 触发一个异常 附带上原因。

另一个选择时允许Elixir来为我们触发异常，，那就是 触发一个匹配错误：
>
    iex(9)> {:ok, config_file} = File.open("config_file")
    ** (MatchError) no match of right hand side value: {:error, :enoent}

尽管，这种方法并不总是最简单的debug方法。它经常是短期够用的。 但有个更好的选择 -- File.open!. 末尾的 **叹号** 是一个Elixir
的惯例 它显示出在错误时函数会触发一个异常 而不是返回一个元祖：{:error, reason }:
>
    iex(9)> config_file = File.open!("config_file")
    ** (File.Error) could not open config_file: no such file or directory
        (elixir) lib/file.ex:1046: File.open!/2
    
这样 我们不用做任何特殊时期 并得到一个很好的错误消息。

## 异常补救 Exceptions rescap
 
尽管异常和使用try-catch 和使用 try-rescue可以用来做一些代码分支 ，这些不是严格的代码分支结构 。这里，实际上，一些关于
cathing和handling异常的章节应该被忽略 。Elixir的哲学是字面量地对待错误 。更经常地 在Elixir标准库中的函数 和你写的函数应该
返回一个元祖 其第一个元素是 :ok 或者 :error  和其值或者错误原因 分别地 这取决于你，和你系统的假设 决定一个:error 是不是
真正的异常，除了这个 ，我们可以广泛地使用模式匹配 或者 ！ 函数来触发 并且广播一个错误给控制进程。

【注  这种方式 被广泛地采用在其他语言中  在golang中 称之为 ok-pattern   ， 在node-js中 异步编程 也是这种函数风格 
function x(): {:ok|:error, return-value|error-reason , callback}】
    
    
## Determinism 决定

在这种分支表达式返回一个值的结果 有很多可强调 ，Elixir 函数式的天性结果
  
JVM java的分支表达式不是内在可决定的 。他们可能从不返回一个值或者退出。
更深地，if then else 字句在java中 也不是自然地返回一个结果，而是 这些表达式 很字面地 ，分叉执行路径。
然而，JVM做了一些事情用于提升性能 在这些执行路径附近 -- 他可能会假设某条路径是唯一的执行路径。
  
JVM中的执行路径  JVM通过展开指令并采用一个捷径在表达式（支分代码）周围  。然而这种优化不是免费的，如果路径的假设不正确，
JVM必须回溯其假设然后 未优化地 继续前行 。 这被称为 **branch miss**（prediction）这经常是很贵的。

ERTS（Erlang Runtime System ）内在不用这种优化 。换之，他牺牲了这种速度 为了确保安全通过类型系统和运行时。ERTS永远不会
branch miss ；就是不能。
【这不是说ERTS 不会有一个更好的性能， HiPE（High Performance Erlang 高性能Erlang）扩展 会提前编译特定模块和函数到本地代码】

为了让ERTS永远不会branch miss，要执行的代码不得不必须是正确的并且是可决定的 。


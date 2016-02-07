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
                length(1) <= 1 -> 1
                true ->
                    middle = div(length(l), 2)
                    left = Enum.slice(1, 0, middle)
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
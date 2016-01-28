Protocols 和 Structs 
------------

Elixir 没有类，但(很惊奇呢)确实有用户定义类型。使用structs和一些惯例

一个简单的struct:
~~~
    
    defmodule Blob do
        defstruct content: nil
    end
    
    iex(1)> c "basic.exs"
    [Blob]
    iex(2)> b = %Blob{content: 123}
    %Blob{content: 123}
    iex(3)> inspect b
    "%Blob{content: 123}

~~~
看起来我们创建了一些新类型，blob 。因为Elixir为我们隐藏了一些东西。默认情况 inspect 识别结构。如果我们使用 structs:false
选项关闭掉它，inspect 结论了blob指的真正特性。
>
    iex(4)> inspect b, structs: false
    "%{__struct__: Blob, content: 123}"

结构的值实际上是一个map 有个key __struct__ 引用结构的模块(此处是Blob )并且剩余的元素包含此示例的keys和values.inspect对
map的实现检查这个 -- 如果你让它 去inspect一个map 此map 包含键值__struct__ 引用到一个模块，他就显示它为一个结构。
 
很多Elixir中内置的类型内部表示为一个结构。
 
内建的协议： Access
===========
 
让我们定义一个Bitmap类型 允许我们访问数字二进制表示中的独立字节。这样做，我们会创建一个结构 其包含一个独立的字段，value。
~~~
    
    defmodule Bitmap do
        defstruct value: 0
    end

~~~ 
内建的Access协议定义了 “[]” 操作符 用来访问集合中的元素。我们可以用此来访问我们值中的字节。所以访问一个bitmap值用
value[0]会返回 最小意义上的字节。实现使用Bitwise模块 此模块随Elixir一起的 -- 带给我们 &&& 和 <<< bitwise和 and 移位操作符
。（注意Access 协议可能会在未来Elixir版本中移除 ）

~~~

    defmodule Bitmap do
        defstruct value: 0
        defimpl Access do
            use Bitwise
            def get(%Bitmap{value: value}, bit) do
                if(value &&& (1 <<< bit)) == 0, do: 0, else: 1
            end
            def get_and_update(bitmap = %Bitmap{value: value}, bit, accessor_fn ) do
                old_value = get(bitmap , bit)
                new_value = accessor_fn.(old_value)
                value = (value &&& bnot( 1 <<< bit)) ||| (new_value <<< bit)
                %Bitmap{value: value}
            end
        end
    end
    
    fifty = %Bitmap{value: 50}
    [5,4,3,2,1,0]
    |> Enum.each(fn bit -> IO.puts fifty[bit] end)
~~~
上面调用流程很像oo中的函数分派过程！
当我们写 fifty[bit] ，我们时间上调用了Access协议。它的处理器看到它的值是一个map 并且map有一个__struct__ 键，它会查找相应
的值并找到Bitmap模块，之后查找Bitmap.Access模块并调用其access函数。传递进原始值和参数 位于中括号间 。get_and_update_in
也类似 它调用我们的get_and_update函数。

## 内置协议： Enumerable

Enumerable 协议在Enum模块中是所有方法的基础。任何类型实现它 就可以被作为集合参数传递给Enum函数。

此协议定义 三个函数：
~~~
    
    defprotocol Enumerable do
        def count(collection)
        def member?(collection, value)
        def reduce(collection, acc, fun)
    end

~~~
count  返回集合中的元素的个数 ，member? 如果元素包含value则返回真值 。 reduce应用给定的函数到集合中的后续值和一个聚合器。
reduce后的值变为下次的聚合器 。（reduce 就是折叠  跟屏风 折叠类似  前面折叠的效果会沉淀下来 传递到后面的折叠过程中），
或许，令人惊奇的是，所有Enum函数可以用这三个术语来定义。

然而，生活不似那么的简单，或许你会使用Enum.find 来查找一个大集合中的值。一旦你发现它，你会终止迭代 。相似地，你想挂起迭代
并在后面的某个时间恢复它。这两个特性在我们讨论流时变得特别重要 ，这运行你懒式迭代一个集合。

让我们看看enumerable协议的count部分的实现 。
~~~

    defmoduel Bitmap do
        defstruct value: 0
    
        defimpl Enumerable do
            import :math, only: [log: 1]
            def  count(%Bitmap{value: value}) do
                { :ok, trunc(log(abs(value))/log(2)) + 1}
            end
        end
    end
    fifty = %Bitmap{value: 50}
    IO.puts Enum.count fifty #=> 6
~~~
我们的count方法 返回一个元祖，包含:ok 和时间的count值，如果我们的集合是not countable(或许他表示来自网络裂解的数据)
，我们可以返回{:error, __MODULE__} .
~~~

    defmoduel Bitmap do
        defstruct value: 0
    
        defimpl Enumerable do
            import :math, only: [log: 1]
            def  count(%Bitmap{value: value}) do
                { :ok, trunc(log(abs(value))/log(2)) + 1}
            end
    
            def member?(value, bit_number) do
                {:ok, 0 <= bit_number && bit_number < Enum.count(value) }
            end
        end
    end
    fifty = %Bitmap{value: 50}
    IO.puts Enum.count fifty #=> 6
    
    IO.puts Enum.member? fifty , 4 #=> true
    IO.puts Enum.member? fifty,  6 #=> false
~~~
然而，:ok 部分的意义稍微有些不同。你通常对你知道集合大小的 返回{:ok, boolean } ，其他情况返回{:error, __MODULE__}
它比较像count ，然而你的原因可能不同，如果你返回:ok 意味你可以快速的断定成员关系 ，如果你返回:error  说明你不能，此时
enumerable代码会简单的执行线性搜索。

最后我们看看reduce 。首先 记得reduce函数的通用形式：
>   reduce(enumerable, accumulator, function)
reduce 从enumerable 轮流接受每个项，把他和聚合器的当前值传递给函数，函数的返回值变成聚合器的下次值。

我们实现的reduce函数同时实现了Enumerable协议，但也附随了一些额外惯例，这些惯例用来管理流迭代结束时的早期停止和暂停。
第一个惯例是 聚合器的值作为元祖的第二个元素传递，第一个元素是动词告诉我们的reduce函数做什么：
- :cont  Continue processing                 继续处理
- :halt  Terminate processing                结束处理
- :suspend Temporarily suspend processing    暂时挂起处理

第二个惯例：reduce函数返回的值是另一个元祖，一样，第二个元素是跟新后的聚合器值，第一个元素回传聚合器的状态。
- :done  这是最后一个值 ---  我们已经到了enumerable的尾部了
- :halted 结束enumeration因为我们被传递了 :halt
- :suspended 对suspend进行响应。
suspended情况比较特殊，不但返回一个新的聚合器，我们也返回一个函数 来表示当前计算的状态，库可用调用这个函数来再次踢出计算
。一旦我们实现了这个，我们的bitmap可参与所有Enum模块的特征。
~~~
    
    defmoduel Bitmap do
        defstruct value: 0
    
        defimpl Enumerable do
            import :math, only: [log: 1]
            def  count(%Bitmap{value: value}) do
                { :ok, trunc(log(abs(value))/log(2)) + 1}
            end
    
            def member?(value, bit_number) do
                {:ok, 0 <= bit_number && bit_number < Enum.count(value) }
            end
    
            def reduce(bitmap,{:cont, acc}, fun) do
                bit_count = Enum.count(bitmap)
                _reduce({bitmap, bit_count} , {:cont, acc}, fun)
            end
            defp _reduce({_bitmap, -1}, {:cont, acc},_fun), do: {:done, acc}
            defp _reduce({bitmap, bit_number}, {:cont, acc}, fun) do
                _reduce({bitmap, bit_number -1}, fun.(bitmap[bit_number], acc), fun)
            end
            defp _reduce({_bitmap, _bit_number}, {:halt, acc},_fun), do: {:halted, acc}
            defp _reduce({bitmap, bit_number},{:suspend, acc},fun),
                do: {:suspended, acc, &_reduce({bitmap, bit_number}, &1, fun), fun}
    
    
        end
    end
    fifty = %Bitmap{value: 50}
    IO.puts Enum.count fifty #=> 6
    
    IO.puts Enum.member? fifty , 4 #=> true
    IO.puts Enum.member? fifty,  6 #=> false
    
    IO.inspect Enum.reverse fifty  # => [0,1,0,0,1,1,1,10]
    IO.inspect Enum.join fifty, ":"  # => "0:1:1:0:0:1:0"
~~~
如果你认为这很复杂 -- 确实 ，这些惯例允许所有可枚举的值用在迫切和延迟处理两种场景。并且当你处理大集合（或者无限大），这
很关键。

## 内建协议： String.Chars

String.Chars 协议用来转换一个值到字符串(二进制),由独立的一个方法组成,to_string.协议用此来做字符串互操作。
~~~
    
    defmodule Bitmap do
        defstruct value: 0
        defimpl String.Chars do
            def to_string(value), do: Enum.join(value, "")
        end
    end
    
    
    # fifty = %Bitmap{value: 50}
    # IO.puts "Fifty in bits is #{fifty}" #=> Fifty in bits is 0110010
~~~

## 内建协议：Inspect
此协议用来inspect一个值 ，规则很简单 -- 如果可以就返回一个有效的Elixir字面表达 不然冠以表达 #Typename .

我们也可以直接把inspect委托给Elixir的默认实现 。
~~~
    
    defmodule Bitmap do
        defstruct value: 0
        defimpl Inspect do
            def inspect(%Bitmap{value: value},_opts) do
                "%bitmap{#{value}=#{as_binary(value)}}"
            end
            defp as_binary(value) do
                to_string(:io_lib.format("~.2B",[value]))
            end
        end
    end
    fifty = %Bitmap{value: 50}
    
    IO.inspect fifty
    IO.inspect fifty, structs: false 
    
    iex(9)> c("bitmap_inspect.exs")
    bitmap_inspect.exs:1: warning: redefining module Bitmap
    %bitmap{50=110010}
    %{__struct__: Bitmap, value: 50}
    [Bitmap, Inspect.Bitmap]
~~~
有点褶皱这里 如果你传递structs: true 给IO.inspect（或者给Kernel.inspect） 他永不会调用我们的inspect函数.
换之，作为元祖来格式化的。

### algebra documents 
一个algebra文档是一个树结构 表示一些你想漂亮打印出它的数据 你的工作就是穿件一个基于你像inspect的数据的结构 ，其后Elixir会
找到一个好的方法显示它的。

在我们的例子中 可以让我们的inspect函数返回一个algebra文档 而不是一个字符串，在文档中我们指出空格和断行在什么地方允许(不
是必须)
~~~
    defmodule Bitmap do
        defstruct value: 0
        defimpl  Inspect, for: Bitmap do
            import Inspect.Algebra
            def inspect(%Bitmap{value: value} , _opts) do
                concat([
                    nest(
                        concat([
                            "%Bitmap",
                            break(""),
                            nest( concat([to_string(value),
                                    "=",
                                    break(""),
                                    as_binary(value)]),
                                2),
                        ]),2),
                        break(""),
               "}"])
            end
    
            defp as_binary(value) do
                to_string(:io_lib.format("~.2B",[value]))
            end
        end
    end
    
    big_bitmap = %Bitmap{value: 123456789123456789}
    IO.inspect big_bitmap
    IO.inspect big_bitmap, structs: false
~~~

## 协议是多态的
当你写了一个函数其行为依据它的参数类型而变，你就正在找一个多态函数。Elixir协议给你了一个整洁并可控的方式来实现它。无论你
是否集成你自己的类型到Elixir库中或者创建一个新库使用了灵活的接口，协议允许你的包行为在一个良构文档和有规律(disciplined 
)方式。
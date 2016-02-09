当有一些Elixir语法基础后，我们就可以开始一些激动人心的事情了

## keywords， maps， 和 dictionaries

更多的集合介绍 ，已经见过了lists和元祖 作为连接的列表或者像数组那样的连续的内存块，然而 仍有一类集合：
关联性数据结构。

Elixir 有不同类的 关联性，k-v 结构，关键字，maps
都是一种字典类型 或者哈希表，尽管底层实现和性能特征不一样

## Keywords

关键字是一种特定名称针对两个元祖的列表，后者结对，每个结对的第一个元素是一个元祖，比如 下面的列表：
~~~

    iex(1)> alist = [{:a, 0}, {:b,2}]
    [a: 0, b: 2]
    iex(2)> alist == [a: 0, b: 2]
    true
    iex(3)> alist[:a]
    0
    iex(4)> alist[:b]
    2
~~~
即 结对的列表和原子--值 的平面列表一样

关键字有很多重要属性使得他们很特别 和 有用：
- keys 键必须是原子
- 键是有序的 对开发者或者使用（插入和删除顺序）
- keys键可被添加多次

keywords 是列表， 线性性能
key搜索 和 元素数量计算会执行很长时间 如果列表过大。
如果常量时间的性能很重用，可以使用maps
Keyword模块有很多跟keyword lists协同工作的功能，比如获取重复key的values: Keyword.get_values/2
>
    iex(6)> Keyword.get_values alist, :a
    [0]

注意顺序和其定义时的一致    

## Maps
创建一个key到value的映射 ，Map是用于存储 key-value 集合的实事标准类型。
>
    iex(7)> my_map = %{'a'=>1, :b => 2 , 3=>5}
    %{3 => 5, :b => 2, 'a' => 1}
    iex(8)> my_other_map = %{a: 1, b: 2, c: 5}
    %{a: 1, b: 2, c: 5}
    
可以看到maps和keyword list 的区别，
简单地，map的可以可以是任何类型，并且顺序不被保证。更多的，我们可以借用关键字列表的键的语法，只是简单的原子。
>
    iex(9)> my_map['a']
    1
    iex(10)> my_map[:c]
    nil
    iex(11)> my_map['c']
    nil
    iex(12)> my_map[:b]
    2

maps中的键是唯一的    
>
    iex(13)> Map.put(my_map, 3, 7)
    %{3 => 7, :b => 2, 'a' => 1}
    iex(14)> Map.put(my_map, 3, 7)
    %{3 => 7, :b => 2, 'a' => 1}
    iex(15)> Map.put(my_map, 3, 8)
    %{3 => 8, :b => 2, 'a' => 1}
    iex(16)>

maps 是 last-write-win 的数据 结构。

##　Dictionaries    
关键字列表和映射是一种形式的字典。其行为遵从像字典数据结构那样。当然　在底层　同我们看到的字典列表那样　他们并不是严格实现
为字典。然而　他们允许我们存储　key-value对 并读取他们（如果知道 或者  key）

有另一个模块 允许我们操作keyword 列表和maps --- Dict
你可能主要到 并没有显式的字典类型（dictionary type）更进一步，你可能注意到 我们欲操作两种不同的类型实现 Dict模块如何做到呢？

尽管没有一个dictionary 类型 ，有一个dictionary协议允许我们使用一个模块来操作 keyword list和maps 。Dict模块是一个单独的API
允许我们同时在keyword lists和maps上操作 就像他们是同一种类型一样。

>
    协议是一种在Elixir中引入多态的手段

更进一步，keyword ，Map 和Dict的APIs 基本一样。如果你需要一个基本的字典 你可以使用keyword 列表或者maps 作为类型并使用Dict
模块来操作该类型。 或者 你可以写一个模块 其接受一个keyword lists或者maps 作为参数 ，因此 Dict模块会是更容易的方式去操作这些
参数，而不用管实际的类型。

然而 有时使用Dict模块不是一个好主意。比如你确实需要访问重复key ，你可能希望使用Keyword模块 互斥的关键字列表。
泛化的API接受任何两种类型中的一种确实对终端用户和正确性都添加了隐性的期望代价。因此，高度推荐 好的测试集应该包括两种类型
针对这种情况。

## 更多的模式匹配

~~~

    iex(16)> my_list = [a: 1, b: 2, c: 5]
    [a: 1, b: 2, c: 5]
    iex(17)> [a: 1, b: 2, c: c]  = my_list
    [a: 1, b: 2, c: 5]
    iex(18)> c
    5
~~~
~~~

    iex(19)> [a: a] = my_list
    ** (MatchError) no match of right hand side value: [a: 1, b: 2, c: 5]
    
    iex(19)> [c: 5, b: 2, a: 1] = my_list
    ** (MatchError) no match of right hand side value: [a: 1, b: 2, c: 5]
~~~
上面的错误说明 keyword lists 要全匹配（all or nothing） ， 匹配顺序要很重要
>
    iex(19)> my_other_list = [a: 0, a: 1]
    [a: 0, a: 1]
    iex(20)> [a: 0] = my_other_list
    ** (MatchError) no match of right hand side value: [a: 0, a: 1]

即使有重复的键，keyword 列表也不做片段关键字列表匹配。

模式匹配对关键字列表也是很困难的。

让我们看看匹配我们的字典类型 -- maps
开始于定义一个基本的mapping：
>
    iex(20)> my_map = %{:a=> 1, :b => 2, 3 => 5}
    %{3 => 5, :a => 1, :b => 2}

key顺序在map中不被保证，所以匹配时跟顺序无关。
>
   iex(21)> %{3 => three, :b => b, :a => a} = my_map
   %{3 => 5, :a => 1, :b => 2}
   iex(22)> a
   1
   iex(23)> b
   2
   iex(24)> three
   5

让我们试一些模式：
>
    iex(26)> %{a:  a} = my_map
    %{3 => 5, :a => 1, :b => 2}

我们可以在maps上做片段匹配 ：
>
    iex(27)> %{} = my_map
    %{3 => 5, :a => 1, :b => 2}

我们用一个空map %{} 来匹配
此列示出空map会匹配任何map。基本等价于_ 匹配。

### Modifying dictionaries

修改keyword list 我们可以使用Keyword 或者 Dict 模块。比如关键字列表中插入一个key
:
~~~

    iex(1)> my_key_list = [a: 1 , b: 2]
    [a: 1, b: 2]
    iex(2)> Keyword.put(my_key_list, :c, 3)
    [c: 3, a: 1, b: 2]
~~~
注意，Keyword.put/3 函数在列表的前面添加一个新key 。让我们试着用Dict模块来执行相同操作:
~~~

    iex(3)> Dict.put(my_key_list, :c, 3)
    [c: 3, a: 1, b: 2]
~~~
不变性
>   
    iex(4)> my_key_list2 = my_key_list
    [a: 1, b: 2]

~~~

    iex(5)> Keyword.put(my_key_list, :a, 5)
    [a: 5, b: 2]
    iex(6)> Dict.put(my_key_list, :a, 5)
    [a: 5, b: 2]
~~~
尽管keyword list 可以存储相同的键多次， Keyword和Dict的 put/3 函数 明确的看出 如果键存在他们会更新键的 ，消息这些不同处。

修改maps 通修改keyword lists很像，仍旧可以使用相同的 put/3 函数
~~~
    
    iex(7)> my_map = %{ :a=>2, :b=>2, 3 => 5 }
    %{3 => 5, :a => 2, :b => 2}
    iex(8)> Map.put(my_map, :c, 4)
    %{3 => 5, :a => 2, :b => 2, :c => 4}
    iex(9)> Map.put(my_map, :a, 7)
    %{3 => 5, :a => 7, :b => 2}
    iex(10)>
~~~
也可以更新同一个key

用模块更新确如预期那样工作。但有一个更好的语法用来更新map：
>
    iex(10)> %{my_map | :a=> 1}
    %{3 => 5, :a => 1, :b => 2}

然而插入一个新keys用此语法就不工作了  
>
    iex(11)> %{my_map | :new_key=> 1}
    ** (KeyError) key :new_key not found in: %{3 => 5, :a => 2, :b => 2}
        (stdlib) :maps.update(:new_key, 1, %{3 => 5, :a => 2, :b => 2})
        (stdlib) erl_eval.erl:255: anonymous fn/2 in :erl_eval.expr/5
        (stdlib) lists.erl:1262: :lists.foldl/3
    
也就是 这种语法只能处理key存在的情形
    
## 性能考虑

当使用keyword list是有明显的性能考量。因为他们实现为列表。
当你使用map时你也要考虑性能。

maps 是最近才加入到Erlang VM中的，并且也只是片段实现（功能还没完？？）
因此 Elixir目前的maps 只有在keys不炒作 a dozen keys 时性能良好 ，为了克服此局限，Elixir提供了HashDict模块和结构。

## Structures和Hash dicts

从通用语言视角看 structures 并不是新概念。

Eixir的structure和maps 很像。 有名称，key到一个value
他们必须被定义在模块内部：
~~~

    iex(11)> defmodule Foo do
    ...(11)> defstruct bar: 'foobar', answer: 42
    ...(11)> end
    {:module, Foo,
     <<70, 79, 82, 49, 0, 0, 4, 220, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 133, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     %Foo{answer: 42, bar: 'foobar'}}
~~~
实例化 
~~~

    iex(12)> %Foo{}
    %Foo{answer: 42, bar: 'foobar'}
    iex(13)> %Foo{bar: 'just bar'}
    %Foo{answer: 42, bar: 'just bar'}
    iex(14)>
~~~

语法上看，结构可以被视为命名maps ，更进一步，他们可以像maps那样被访问和更新：
>
    iex(14)> foo = %Foo{}
    %Foo{answer: 42, bar: 'foobar'}
    iex(15)> foo.answer
    42
    iex(16)> %{foo | bar: 'bar'}
    %Foo{answer: 42, bar: 'bar'}
    iex(17)>

更新结构时 并不需要前缀结构名称 但添上也无害
>
    iex(17)> %Foo{foo | bar: 'bar'}
    %Foo{answer: 42, bar: 'bar'}

同map一样 使用管道符 |  语法来更新不存在的key时会失败的：
>
    iex(18)> %Foo{foo | foo: 'foo'}
    ** (CompileError) iex:18: unknown key :foo for struct Foo
        (elixir) src/elixir_map.erl:185: :elixir_map."-assert_struct_keys/5-lc$^0/1-0-"/5
        (elixir) src/elixir_map.erl:62: :elixir_map.translate_struct/4

相似地创建时 使用不存在的key一样失败    
>
    iex(18)> %Foo{foo: 'foo'}
    ** (CompileError) iex:18: unknown key :foo for struct Foo
        (elixir) src/elixir_map.erl:185: :elixir_map."-assert_struct_keys/5-lc$^0/1-0-"/5
        (elixir) src/elixir_map.erl:62: :elixir_map.translate_struct/4
    iex(18)>

## Yet another dictionary type 另一个字典类型

如前所述，如果map中的keys过多 你就应该使用HashDict 结构 HashDict keys使用哈希算法 底层数据结构使用结构 实现
 
使用HashDict 结构其接口同使用keyword lists maps 或者Dict 模块类似。 
>
    iex(18)> my_dict = HashDict.new
    #HashDict<[]>
    iex(19)> my_dict_2 = HashDict.put my_dict, :foo, 42
    #HashDict<[foo: 42]>
    iex(20)> my_dict_3 = Dict.put my_dict_2, :bar, 'foo'
    #HashDict<[foo: 42, bar: 'foo']>

HashDict模块可以操作HashDict结构 Dict模块也可以 
尽管HashDict实际不是一个map，它定义了协议 或者更确切地，如果调用特定函数应该做什么。对HashDict协议的实现是一个wrapper
around在HashDict模块自己（自己实现自己？）。

重申，此模块存在的理由是 map 在存储大量pairs时 的性能问题。不然 其行为跟maps相似。

## Flow-based programming 基于流的编程
基于流的编程或者使用管道的编程 是一种指定 处理特定问题的的方式 术语是流 两个互联的单元连接

基于流的编程定义了一系列可被执行的操作序列，序列中的每个元素定义了特定的计算，将被传递给下个序列。暂时忽略类型，每个单元
相互独立，每个都可以被修改且不显著影响流中的其他组件。
 
流式编程天然需要函式编程的不变性构造 因为每个元素会在流上被计算，必须是可计算并且不影响原始集中的其他元素。
 
 回到组合性讨论，程序不光关于有用的输出，也关于可组合组件。 在某些语言中这些组件是对象。然而，对象不是真正的最可组合的组件
 ，函数才是，至少 比对象更可组合。
 
 基于流的编程就是一个好例子 示出了对象实际不是自然的可组合对象。想下，你如何组合对象来产出一个流或者计算序列。
 
 和组合 链式函数对比，blocks已经在哪里：map，filter reduce 已经被定义了 ，实际上 当你企图在oo语言中生出一个流时，在大量
 时间后，方案也会是对函数式中 的map 和 reduce 版本的重塑 。
 
组合函数来穿件流 被证明是概念化的更简单模型。每个单元 只是一个函数 某种形式的修改 更易的追踪。他们不是对象 也不必在心智上
封包函数来追踪器影响。

流的执行模型生出很多结果，因为每个元素的处理都独立其他的，这是一个很容易的并行化切点。
比如，我们可以让流的阶段在其自己的进程中，并且每个流段的互联只是传递到下个流程中的消息。或者，作为另一个例子，每个元素可被
在其自己的进程中处理 。

如果流段间的处理完全不依赖，那么并发 并行就更好处理了

Flow-based programming 也有另一个名字 ---  stream processing 。flow或者stream的类比都一样。我们都在说的同一个事情：
处理信息的方式不光有效，而且更高效和可组合地。建设性地，如果我们能组合函数，我们就可以组合流。
通过组合流，我们可以创造另一个块来构造更大的块（blocks）。

## Stream processing and Elixir

因为Elixir是函数式，流处理的在Elixir中很简单，我们有这样的函数：Enum.map/2, Enum.filter/2 和 Enum.reduce/2 

|>  流操作符 我们可以从左到右自然地表述我们的计算。

>
    iex(21)> defmodule MyMap do
    ...(21)> def map([],_), do:  []
    ...(21)> def map([h|t], f), do: [f.(h) | map(t,f)]
    ...(21)> end
    {:module, MyMap,
     <<70, 79, 82, 49, 0, 0, 4, 236, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 163, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:map, 2}}
    iex(22)> MyMap.map([1,2,3,4,5] , fn (x)  ->x * x end)
    [1, 4, 9, 16, 25]

如果我们想用range代替 我们可以用Enum.to_list/1 来转换 之后传递结果给MyMap.map/2 函数
>
    iex(23)> MyMap.map(Enum.to_list(1..5) , fn (x)  ->x * x end)
    [1, 4, 9, 16, 25]
    
来使用流管道操作符：
>   
    iex(24)> 1..5 |> Enum.to_list |> MyMap.map fn (x) -> x * x end
    [1, 4, 9, 16, 25]

读顺序： 我们可以创建一个范围从 1到5的 之后传递给 Enum.to_list/1 传递结果给MyMap.map/2
    
Elixir的 |> 操作符很像UNIX的操作符 | 
我们用计算结果 传递到下个 无限次的链式传递多次。
    
流结果 总是作为下个函数的第一个参数（也就是 如果有多个参数时 你只需要传递去除第一个参数后的其余参数 就行了）。

## Processing with the Enum module

>
    iex(25)> 1..100 |>
    ...(25)> Enum.filter(fn(x) -> rem(x,2) != 0 end) |>
    ...(25)> Enum.take(10)
    [1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
    
>
    iex(1)> 1..100 |>
    ...(1)> Enum.take_every(2) |>
    ...(1)> Enum.take 10
    [1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
    
>
    iex(2)> 1..10 |>
    ...(2)> Enum.map( fn(x) -> x*x end ) |>
    ...(2)> Enum.sum
    385
    
>
    iex(3)> 1..10 |>
    ...(3)> Enum.map( fn(x) -> x*x end ) |>
    ...(3)> Enum.reduce( fn(x, acc) -> x + acc end )
    385
    
>
    iex(4)> 1..10 |>
    ...(4)> Enum.map( fn(x) ->x*x end ) |>
    ...(4)> Enum.reduce(1, fn(x,acc) -> x * acc end)
    13168189440000
    
## Processing with the Stream module
    
同Enum模块类似 Elixir有个Stream 模块。他们的极大不同是 Stream 是懒惰的lazy 。
即直到不得已Stream模块才创建集合 ，
通过Stream模块映射的一个函数结果不会得到全部的map知道显式请求才行。
    
## Greedy versus lazy 贪婪 VS 懒惰

集合是贪婪 懒惰 是什么意思？

贪婪集合或者枚举是一种理解被实现的集合 当下可用
    
惰性集合是直到最后一刻才被实现    以promise方式返回

无限集合

使用懒计算 同无限集合工作很容易 。

同无限集合相关，或许我们的数据缓慢拉自一些I/O设备，或许是一个文件，internet上的某些设备，等等。我们可以对流使用懒计算 不用
等待I/O设备完成读或者等待拉取的完成。

在延迟集合上的修改表示 更准确地表示为函数的列表 而不是 值的列表。这样函数可以被延迟调用 

## 一些例子
>   
    iex(1)> 1..100 |>
    ...(1)> Stream.filter( fn(x) -> rem(x,2) != 0 end ) |>
    ...(1)> Stream.take(10) |>
    ...(1)> Enum.to_list
    [1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
    
>   在Elixir中调用Erlang模块 可以在模块前冠以冒号前缀

计算下及时集合和流式延迟的耗时：
>
   iex(1)> 1..100 |>
   ...(1)> Stream.filter( fn(x) -> rem(x,2) != 0 end ) |>
   ...(1)> Stream.take(10) |>
   ...(1)> Enum.to_list
   [1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
   iex(2)> stream_f = fn() -> 1..1000000 |>
   ...(2)> Stream.filter(fn(x) -> rem(x,2) != 0 end ) |>
   ...(2)> Enum.take(10) end
   #Function<20.54118792/0 in :erl_eval.expr/5>
   iex(3)> enum_f = fn() ->1..1000000 |>
   ...(3)> Enum.filter(fn(x) -> rem(x, 2) != 0 end ) |>
   ...(3)> Enum.take(10) end
   #Function<20.54118792/0 in :erl_eval.expr/5>
   iex(4)> :timer.tc(enum_f)
   {1328000, [1, 3, 5, 7, 9, 11, 13, 15, 17, 19]}
   iex(5)> :timer.tc(stream_f)
   {0, [1, 3, 5, 7, 9, 11, 13, 15, 17, 19]}

可以看出流方法耗时很小（这里是0 基本是无延迟） 而enum_f 由于要遍历整个列表 所以耗时比较多。
    
## Koolaid 
虽然 但是

api都有其适用场景 有些情况仍需要避免使用他们。

 
流的天性，在某些特定环境下会比全枚举要慢 ， 先请求一个promise 之后 请求填充他需要时间。
 如果list的数量很小，或者promise-填充完成 循序比数据的延迟更大 ，那么使用Enum模块 ，Stream模块更适合I/O 任务。
 从文件或者web servide 请求数据 更适合Stream模块。
 
 ## Graphs 图
 
 简单图有一些有趣点 用于查询或搜索，比如 最短路径 最小跨度树 等
 
## 对树的简单介绍

图来自数学 是一种结构 用来描述一些节点或者顶点 和一些 连接或者边 。邻接点是有单边连接的节点。
在内存中表示图可以通过邻接矩阵完成，矩阵的每行和列对应图中节点 矩阵中的每个元素是 0 或者 1 用来表示节点是否连接。

比如下面的邻接矩阵：
>   
        A   B   C
      A 0   1   1 
      B 1   0   1
      C 1   1   0
      
简单图是个有限图 没有环或者多边 。这样的图可表示为邻接列表 。上面的图除了用矩阵表示，也可以使用下面的列表表示：
>
      [{:b, :c}, {:a, :c}, {:a, :b}]
      
这是元祖的列表。我们显式的索引了元素 （顺序地）
A的邻居在第一个元素定义，B的邻居定义在第二个元素，C 的定义在第三个元素

我们可以继续使用list 和 使用keyword lists 显式示出谁的邻居是谁：
>
    iex(7)> k3 = [a: {:b, :c} , b: {:a, :c}, c: {:a, :b}]
    [a: {:b, :c}, b: {:a, :c}, c: {:a, :b}]

我们称其为k3 因为他是一个K3 或者全图 有三个节点。

纯语义地术语，技术上不是一个列表，而是 从某些方面看，更好的表示 因为我们可以使用好的，显式语法用来获取邻居或者特定节点：
>
    iex(8)> k3[:b]
    {:a, :c}

在计算中另一类常见的典型图是 directed acyclic graph(DAG) , Directed意即图的连接边是有方向的 ，然而早期 ，变是双向的。
Acyclical 指图中无环 ，即 没有顶点模式可以被访问并会到起始顶点 。

同简单图类似 我们可以用邻接列表表示DAG
>
    
iex(9)> dag = [a: {:b, :c}, b: {:c, :d}, c: {:e}, d: {:e}, e: {} ]
[a: {:b, :c}, b: {:c, :d}, c: {:e}, d: {:e}, e: {}]

此情况下 节点A 认为是source 节点E 认为是 sink 。

## 节点祖先

当使用有向图时常见的问题就是获取节点的祖先，或者更常见地，任意两个节点的共同祖先



Stream  Lazy Enumerables
==================

在Elixir中，Enum模块是贪婪的 ，
即 当你传递一个集合，它底层会消费掉集合的所有内容，也即其结果典型的是另一个集合

比如下面这个管道：

~~~[elixir]
    
    [ 1, 2,3,4,5 ]
    |> Enum.map(&( &1 * &1 ))
    |> Enum.with_index
    |> Enum.map(fn {val , idx} -> val - idx end )
    |> IO.inspect

~~~
为了得到最后的输出 中间过程需要生成4个lists   
由于Enum是自包含的 ，对Enum方法的每次调用 都接受一个集合 返回一个集合 （极大的浪费 不断的产生中间过程集合）

但我们真正想要的 处理集合中的元素 不不要存储中间的过程集合 ，只是需要把当前元素从一个函数传递到另一个函数
这就是流 做的事 。

流是一个组合的枚举器
------------

创建
iex>  s = Stream.map [1,3,5,7] , &( &1 + 1 ) # 跟Enum.map 返回的不一样哦！
让流开始给我们结果，只要将其看做集合 然后传递给Enum模块中的某个方法即可
Enum.to_list s 

因为流是 可枚举的 ，所以可以将流从一个流函数传递给另一个 ，因此我们称流式可组合的 。

~~~[elixir]

    iex(3)> squares = Stream.map [1,2,3,4] , &( &1 * &1 )
    #Stream<[enum: [1, 2, 3, 4], funs: [#Function<44.120526864/1 in Stream.map/2>]]>
    iex(4)> plus_ones = Stream.map squares , &(& + 1)
    ** (CompileError) iex:4: nested captures via & are not allowed: &+1
        (elixir) src/elixir_fn.erl:108: :elixir_fn.do_capture/4
        (stdlib) lists.erl:1353: :lists.mapfoldl/3
        (stdlib) lists.erl:1354: :lists.mapfoldl/3
    iex(4)> plus_ones = Stream.map squares , &(&1 + 1)
    #Stream<[enum: [1, 2, 3, 4],
     funs: [#Function<44.120526864/1 in Stream.map/2>,
      #Function<44.120526864/1 in Stream.map/2>]]>
      
      iex(5)> odds = Stream.filter plus_ones , fn x -> rem(x,2) == 1 end
      #Stream<[enum: [1, 2, 3, 4],
       funs: [#Function<44.120526864/1 in Stream.map/2>,
        #Function<44.120526864/1 in Stream.map/2>,
        #Function<41.120526864/1 in Stream.filter/2>]]>
        
        iex(6)> Enum.to_list odds
        [5, 17]

~~~
当然我们在实际工作中 可能这样做：

~~~[elixir]
    
    [1,2,3,4]
    |> Stream.map(&( &1 * &1 ))
    |> Stream.map( &(&1+1) )
    |> Stream.filter(fn x -> rem(x,2) == 1 end )
    |>  Enum.to_list

~~~
链式的流表现为函数的列表 ， 每个函数按顺来作用于流中的每个元素

流不不仅仅为了列表，越来越多的elixir模块支持流了。
~~~[elixir]
    
    IO.puts
        File.open!('pipeline.exs')
        |> IO.stream(:line)
        |> Enum.max_by(&String.length/1)

~~~
魔法是 对IO.stream 的调用 会把IO设备（此代码段中打开的文件）转换成每次一行的流。
这是个非常有用的概念，以至于有个简版写法：
~~~[elixir]
    
    IO.puts
        File.stream!("stream1.exs")
        |> Enum.max_by( &String.length/1)

~~~
好的是此时没有中间存储，坏消息是会比前个版本慢2倍左右。
然 可以考虑我们从远程服务器读数据的情况 或者从外部传感器（可能读取温度）读取数据。后续的行可能返回的比较
慢，但他们可能源源不断的到来。 如果使用了Enum实现 我们将不得不等到所有的行到来后才能开始处理，有了流我们可以在
他们到来时就处理。

无限流
=====

因为流式懒货 ，我们不必等整个集合全部可用 
比如
~~~[elixir]

    iex> Enum.map(1..10_000_000, &(&1+1)) 
    |> Enum.take(5)

~~~
会花费8秒中来处理，Elixie 会创建10亿个元素的列表 ，之后从中取前五个。

但如果改写为
~~~[elixir]

    iex> Stream.map(1..10_000_000 , &(&1+1))
    |> Enum.take(5)
~~~
结果立即就处理了！
take调用只需要5个，从流获取，一旦够数就不会进行更多的处理了。

### 创建自己的流

流在Elixir库中是单独实现的 --------- 没有特殊的运行时支持。流的实现相当复杂

我们可以借助一些函数来实现我们自己的流，包括：cycle，repeatedly ，iterate，unfold，已经resource
。

- Stream.cycle

Stream.cycle 接受一个可枚举的元素，并返回一个包含可枚举元素的无限流。当到达尾部时，又从头部开始重复，无限
的往复。
~~~[elixir]

    Stream.cycle(~W{ green white}) |> Stream.zip(1..5) 
    |> Enum.map( fn {class ,value} -> ~s{<tr class="#{class}"> <td> #{value}</td></tr> \n } end )
    |> IO.puts
~~~

-   Stream.repeatedly

当新值每次需要时 Stream. 重复使用一个函数并调用它
~~~[elixir]
    
    Stream.repeatedly(fn -> true end )
    |> Enum.take(3)
    # |> IO.puts
    
    Stream.repeatedly( &:random.uniform/0 )
    |> Enum.take(3)
    |> IO.inspect


~~~

-  Stream.iterate

Stream.iterate(start_value , nex_fun ) 生成一个无限流。
参数一是开始值，下一个值通过为函数提供此值来生成，只要流被使用 返回的每个值是next_fun作用于前一个值
调用的结果
如：
~~~[elixir]

    Stream.iterate(0 , &( &1 + 1 ))
    |> Enum.take(5)
    |> IO.inspect

~~~

-   Stream.unfold

Stream.unfold 跟iterate有关，两者都是关于值输出到流 值被传递到下次迭代中，你提供一个初始值和一个函数。
函数使用参数创建两个值，以元祖形式返回，第一个值是本次流迭代的返回值 ，第二个是将被传递到下次迭代中的值
。如果函数返回nil 流迭代终止。

听起来很抽象，但unfold相当有用，是一种创建无限流的通用手法，那里每个值是前个状态的的某种函数。
关键点就是生成器函数 ，通用形式：
> fn state -> { stream_value , new_state } end 

比如Fibonacci数
~~~[elixir]

    Stream.unfold({0,1} , fn {f1,f2} -> {f1,{f2,f1+f2}} end )
    |> Enum.take(15)
    |> IO.inspect
~~~

-  Stream.resource

如何跟外部资源交互，实现我们自己的流
比如文件流 ，需要打开文件，返回后续的行，在结尾关闭文件
数据库 结果集游标 转换为值的流 ，当流开始时 不得不执行一个查询 返回每一个行作为流的值 ，在结尾处关闭掉产下 。
这些都涉及到 Stream.resource .

Stream.resource 构建与 **Stream.unfold**之上 ，做了两个改变

-  给unfold的首参 是传递给迭代函数的初始值 ，但如果此值是一个资源 ，我们并不想打开它直到流开始传送值 ，他们可能在我们创建
 流后很久才被打开。围绕这个情况，resource要的不是一个值 而是一个函数（该函数才返回那个值） ，这是第一个改变。
 
-  第二 ，当资源 流完成时 我们需要关闭它，这是Stream.resource第二个参数干的事 ---- 他采用最后的计算值并在需要时关闭资源。
    
    比如这个库文档中的例子：
    >
         Stream.resource( 
                        fn -> File.open("sample")  end ,
                        fn file -> case IO.read(file, :line) do 
                              line when is_binary(line) -> { [line] ,file }
                              _ -> {:halt , file}
                              end
                          end ,
                          fn file -> File.close!(file) end
                     )


当流被激活时 第一个函数打开一个文件 ，并将之传递给第二个函数 ，此函数读取文件 一行接一行 ，返回一行和文件做为一个元祖
或者返回一个 :halt 元祖 在文件末尾处 ，第三个函数关闭文件

### 流实战

和函数式编程 以一种新的方式看待问题 一样 。流 也要求你 看待迭代和集合以一种新的视角 并不是每次迭代情况都不要一个流 。
 但当你需要延迟处理 直到你使用数据时 或者当处理大数据量的东西时（并不需要一次全部生成） 可考虑使用流  。
 
 
## Collectable 协议
 
Enumerable协议 让我们可以在一个类型上（比如 集合）迭代元素 ，我们可以获取元素。
Collectable 从某种意义上是其相反的东西 。它允许我们通过插入元素来构建一个集合 。

并不是所有的集合都是collectable ，比如Ranges 区间 就不可以添加新元素！

collectable api 是很底层的 ，所有 一般典型的使用Enum.into 来访问，比如 把区间中的元素注入到一个空的列表中
>  Enum.into 1..5 , []

如果列表不为空，新元素被添加到尾部 。
> Enum.into 1..5 , [100  , 101 ]

输出流式collectable 的 所有 ，下面的代码 惰性的拷贝标准的输入 到输出 ：

> iex> Enum.into IO.stream(:stdio , :line ) , IO.stream(:stdio , :line) 

## Comprehensions 

当写函数式代码时 ，经常map并过滤集合 ， 为了使生活更愉快简单 （代码更可读） ，Elixir提供了 通用目的捷径 ：推导(comprehension)

思想很简单 ： 给一个或者多个集合 ，提取所有的值组合 ， 可选的过滤这些值 ，之后 利用剩余的值来生成新的集合 。

语法 大致如： result = for generator or filter ... [, into : value ] , do: expression 

列如：
> iex> for x <- [1,2,3,4,5] , do: x*x 

> iex> for x <- [1,2,3,4,5] , x < 4 , do: x*x

生成器指定了你如何从集合中取值 : pattern <-  list 只要匹配patter的变量 在接下来的推导中都可用 （包括 block）
比如  x <- [1,2,3] 推导首次将x设置为1 之后设置x为2 ，依次类推

如果有两个 其操作会嵌套： 
x <- [1,2] , y <- [5,6]

如果运行接下来的推导 回事  x=1 , y =5 ,x=1 , y= 6 ; x=2 ,y=5 ; 以及 x=2 , y=6 .
 
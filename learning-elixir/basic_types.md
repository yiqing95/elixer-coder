

Remember, Elixir functions are described by {name}/{arity}.


Elixir 实际没有booleans 他们只是原子atoms
~~~[iex]

    iex(23)> is_atom(false)
    true
    iex(24)> is_atom(true)
    true
    iex(25)> is_boolean(:false)
    true
    iex(26)> is_boolean(:someKey)
    false
    
    iex(27)> 1 == 1.0
    true
    iex(28)> 1 == '1'
    false
    iex(29)> 1 == "1"
    false
    iex(30)> 1 == true
    false
    
    iex(31)> 1 < :atom
    true
~~~

跨类型比较
number < atom < reference < function < port
< pid < tuple < maps < list < bitstring
顺序不必记住 但要知道其存在。


## 字符串
~~~
    
    iex(32)> IO.puts("Hello, \nWorld!")
    Hello,
    World!
    :ok
~~~
string interpolation.

~~~~

    iex(33)> "Hello, #{:world}"
    "Hello, world"
~~~~
模块方法：
~~~

    iex(34)> String.reverse "Hello, world!"
    "!dlrow ,olleH"
    iex(35)> String.length "Hello, World!"
    13
    iex(36)> String.at "Hello, World" , 6
    " "
~~~

## (Linked)Lists

primitive 原生类型

异构类型列表
任何类型都可以作为元素
>  
     iex(37)> [1,2,4,:ok,6,true]
     [1, 2, 4, :ok, 6, true]
     
操作符 
-  ++/2 用来连接两个列表
    ~~~
    
        iex(38)> [1,2,3] ++ [4,5,6]
        [1, 2, 3, 4, 5, 6]
    ~~~
- --/2 操作符 用来求差两个列表
    >   
        iex(39)> [1,2,true, false, true] -- [true, false]
        [1, 2, true]
    
    一对一移除 不计入重复        
-  hd/1 抓取列表的头
    >   
        iex(40)> hd([1,3,4,5])
        1
-  tl/1 抓取列表的尾元素
>
        iex(41)> tl([1,3,4,5])
        [3, 4, 5]
        
    注意此操作不是返回5 哦！ 就是剩余头部一个元素1 外的其余元素构成的列表
    在函式编程中 常规地 一个列表由头元素跟尾列表构成 
    >
        iex(42)> hd []
        ** (ArgumentError) argument error
            :erlang.hd([])
        iex(42)> tl []
        ** (ArgumentError) argument error
            :erlang.tl([])
        
    空列表上调用 hd 与 tl 报错的

## 关于strings的额外东西
    
在C中 我们知道字符串实际是字符数组，并且 char只是 unsigned integer 。
即使 在Elixir中我们也不能避免这个。
>
    iex(45)> is_list('hello')
    true
    iex(46)> [104, 101, 108, 108, 111]
    'hello'

看到了字符串有两种形式。 这个跟Erlang早期历史有关，Erlang早期主要围绕报文交换构建的 Bits和binaries在当时更重要。字符串处
理并不是那么重要，所以早期的Erlang库在字符串处理上都是用原始自然的方式搞的，作为字符列表（或者真正的数字 列表）

在这种情况下 to_string/1 to_char_list/1 帮助你相互转换
>
    iex(49)> to_string([67,89,89])
    "CYY"
    iex(50)> to_char_list("hello")
    'hello'

to_string/1 函数不仅仅是一个通用的转换功能 字符列表到字符串， 
你也可以传递number和其他类型 他们都实现了String.Chars 协议 来获取其字符表现输出。

## Ranges 范围

和list类似，，你可以用 ../2 来创建一个列表。比如  1..100 
>
    iex(51)> 1..100
    1..100
    
Elixir 并没有展开它，在Elixir中range视为lazy惰性的。
    
## Tuples 元祖
同Lists 元祖也可以持有任何值    
>
    iex(52)> t = {1, 2, :ok, true, "hello"}
    {1, 2, :ok, true, "hello"}

跟List的区别：元祖存储元素在内存上是连续的，List天然的是链表，所以用index访问list会比较慢 O(n)  
  
- 大小 tuple_size/1 

>
    iex(53)> tuple_size(t)
    5
    
- elem/2 访问元祖中指定索引的元素（索引是0基的 从零开始）    
>   
    iex(54)> elem(t, 3)
    true
    
- put_elem/3 函数来插入(读替换)元祖中的值  
>
        iex(55)> put_elem(t,3,false)
        {1, 2, :ok, false, "hello"}
        
        iex(56)> t
        {1, 2, :ok, true, "hello"}
        iex(57)>
记住 Elixir是无边缘效应的语言，put_elem/3 函数并不修改即有元祖，而是创建一个新的。
        
## Tuple 还是 List    元祖还是列表？
既生瑜何生亮
        
内部布局不一样，对于元祖，访问任意独立元素比较廉价，然而 增加或者插入更多的元素到元祖中就昂贵了。
对于列表，访问指定的独立元素需要遍历列表，但前部添加元素是廉价的，常量时间，添加元素需要遍历。
                
二进制
=============
二进制类型给了我们很多超越位和字节功能。      
          
二进制，有时称之为位串，
>
   iex(57)> <<1, 2, 4 >>
           <<1, 2, 4>>   
   iex(58)> <<255, 255, 256>>
   <<255, 255, 0>>  

255是极限
>
    iex(59)> <<256 :: size(16) >>
    <<1, 0>>
    iex(60)> <<65535 :: size(16)>>
    <<255, 255>>
    iex(61)> <<65536 :: size(16)>>
    <<0, 0>>
    
增加一位来存储
>   iex(62)> <<65536 :: size(17)>>
    <<128, 0, 0::size(1)>>     // 位对齐？
    
    
## 更多关于字符串的
双引号的字符串，是真正的字符串
早期，Erlang，不需要字符串，Erlang代码 是面向用户的代码，字符串处理认为是次要的。位处理占据主要位置。语言主要用于报文数
据的处理，这些数据主要就是位和字节。

当需要给Erlang添加字符串，和字符串处理时。引入的变化为了不破坏现有的一些系统，决定使用现有的类型。
最后，字符串要么是数字的列表，或者真正的二进制
>
    iex(63)> is_binary("hello")
    true
    iex(64)> is_binary(<<"hello">>)
    true
    iex(65)> is_binary('hello')
    false
    iex(66)> <<"Hello">> === "Hello"
    true

上面都说明了字符串就是二进制或者相反也成立。
Elixir中的字符串实际是UTF-8二进制 ，有一个String模块可用于UTF-8 二进制 Erlang中的字符串是指字符的列表，有一个string模块
但它不是UTF-8可感知的 对有些字符串的处理会不正确。

## 一些更多的内建类型


## Functions 

在Elixir，Erlang或是其他函数式语言中是一等公民， 意即我们可以像其他类型那要引用或者传递，我们可以将之作为函数的参数传递
。给那个函数注入某些功能，或者可以使用函数传递作为组成程序的另一种形式。
>
    iex(67)> double = fn x -> x * 2 end
    #Function<6.54118792/1 in :erl_eval.expr/5>

结果示出函数如何被解析和内存中存储的。
>
    iex(68)> double.(2)
    4
    iex(69)> Enum.map(1..10, double)
    [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

此例中看到函数被调用     还有著名的map函数  参一是一个range 参二就是我们的函数 该函数会逐个作用到参一的每个元素 并作为新
    的元素返回的。

## Process IDs

另一个Erlang内建类型是process IDs(PIDs), 不要跟常规的OS PIDs混淆。在Erlang程序中 所谓的进程 是Erlang中的进程，而不是其他
概念。
PIDs用来引用 在Erlang进程间 讯号或者消息通信 ，是用来表示每个进程和其消息箱的，如果没有消息箱标识符，我们就不知道如何发送
消息给它。
Process.list/0: 查看当前Erlang虚拟机中的进程列表
>
    iex(70)> Process.list
    [#PID<0.0.0>, #PID<0.3.0>, #PID<0.6.0>, #PID<0.7.0>, #PID<0.9.0>, #PID<0.10.0>,
     #PID<0.11.0>, #PID<0.12.0>, #PID<0.13.0>, #PID<0.14.0>, #PID<0.15.0>,
     #PID<0.16.0>, #PID<0.17.0>, #PID<0.18.0>, #PID<0.19.0>, #PID<0.20.0>,
     #PID<0.21.0>, #PID<0.22.0>, #PID<0.23.0>, #PID<0.24.0>, #PID<0.25.0>,
     #PID<0.26.0>, #PID<0.27.0>, #PID<0.31.0>, #PID<0.34.0>, #PID<0.35.0>,
     #PID<0.36.0>, #PID<0.37.0>, #PID<0.38.0>, #PID<0.39.0>, #PID<0.40.0>,
     #PID<0.42.0>, #PID<0.43.0>, #PID<0.44.0>, #PID<0.45.0>, #PID<0.48.0>,
     #PID<0.49.0>, #PID<0.50.0>, #PID<0.51.0>, #PID<0.52.0>, #PID<0.53.0>,
     #PID<0.54.0>, #PID<0.55.0>, #PID<0.57.0>]
    iex(71)>

## 不变变量和模式匹配

在函式编程中经常被误解的一个概念就是赋值。  赋值实际不存在！
Elixir中 = 不是赋值操作符，而是一个匹配操作符。
Elixir试图匹配=的左侧边 和其右侧边。

>
    iex(71)> list = [1, 2, 3 ]
    [1, 2, 3]
    iex(72)> [a,b,c] = list
    [1, 2, 3]
    iex(73)> a
    1
    iex(74)> b
    2
    iex(75)> x
    ** (CompileError) iex:75: undefined function x/0
    
    iex(75)> c
    3

Elixir 总是试图让左侧边的匹配右侧
    
相似地，字面值也可以用于表达式匹配:
>       iex(76)> [a, 2,c] = list
        [1, 2, 3]

## 使用下划线

在很多语言中 _ 被用来表示值不希望绑定到任何值上 或者我们不关心它（弃用 占位而已）。  
>
      iex(77)> [a, _, c] = list
      [1, 2, 3]
      iex(78)> a
      1
      iex(79)> c
      3
      iex(80)> _
      ** (CompileError) iex:80: unbound variable _

在任何Elixir代码中，我们看到下划线，我们知道我们可以忽略它，其次 实际上Elixir将不会允许我们使用它一次来帮助我们确定我们
不会无用它的值。

## 更多的模式匹配

IEEE-754 标准 
计算机如何在内从中处理浮点数。

>
    iex(80)> <<sign::size(1) , exp::size(11),mantissa::size(52)>> = <<3.14159::float>>
    <<64, 9, 33, 249, 240, 27, 134, 110>>
    iex(81)> sign
    0
    iex(82)> exp
    1024
    iex(83)> mantissa
    2570632149304942
    iex(84)> (1 + mantissa / :math.pow(2, 52)) * :math.pow(2,exp - 1023)
    3.14159
        

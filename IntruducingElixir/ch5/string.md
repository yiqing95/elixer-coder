在程序中使用原子来发送消息很棒，即使程序员可以记住这些消息。但他们并不是设计用来在erlang进程之外的
上下文通信。如果你需要组装句子或者准备信息，你会需要某些更flexible的东西，字符串就是你需要的结构。

> IO.puts("Look out below! ")

双引号间的内容就是一个字符串。字符串是字符序列，如果字符串中有双引号 那么需要使用反斜杠(backslash)
进行转义  \".  \n是个换行符。为了包含反斜杠 你必须用两个 \\ .

Elixir 也提供了用来创建新字符串的操作符，最简单的就是 连接 <>
>
    iex(6)> "el" <> "ixir"                                                                        
    "elixir" 
    iex(7)> a = "el"                                                                              
    "el"                                                                                          
    iex(8)> a <> "ixir"                                                                           
    "elixir" 

Elixir 也有字符串  篡改 {} 
>   IO.puts("#{n} yields #{result} ")
当碰到 字符串中的#{} Elixir处理其内容得到结果 如果必要将之转换为字符串 并合并这些片段到一个单独的字符串。
这种串改只发生一次。 
>
    iex(9)> a  = "this"                                                                           
    "this"                                                                                        
    iex(10)> b = "The value of a is #{a}."                                                        
    "The value of a is this."                                                                     
    iex(11)> a = "that"                                                                           
    "that"                                                                                        
    iex(12)> b                                                                                    
    "The value of a is this."                                                                     
    iex(13)>    

  在#{} 此间可以放任何返回一个值的东西：变量，函数调用，或者部件上的操作

### 字符串 篡改 的适用性
只适用那些值已经是字符串，或者可以自然地转变为字符串的（比如数字）。如果你想放入其他类型的值
那么最好先用inspect函数封包下 。
>
    iex(1)> x = 7*5
    35
    iex(2)> "x is now #{x}"
    "x is now 35"
    iex(3)> y = {4,5, 6}
    {4, 5, 6}
    iex(4)> "y is now #{y}"
    ** (Protocol.UndefinedError) protocol String.Chars not implemented for {4, 5, 6}
        (elixir) lib/string/chars.ex:3: String.Chars.impl_for!/1
        (elixir) lib/string/chars.ex:17: String.Chars.to_string/1
    iex(4)> "y is now #{inspect y}"
    "y is now {4, 5, 6}"
    iex(5)>

## 字符串比较 
== vs ===

后者是严格比较

String 和 Regex 模块有常用的字符串操作实现。可以前往看之

## 多行字符串

亦称heredoc  
比较适用创建文档 但也可做他用

~~~elixir

    multi = """
        this is multiline
        string , also called a heredoc.
    """
~~~

## Unicode
Elixir 跟Unicode（utf8）相处良好。String.length/1 函数返回unicode编码的数量。返回不必和字符串中的字节数相同。如果你确实需要
知道字节数可以使用函数 byte_size/1 
>
    ...

## Character Lists
elixir的字符串处理大部分源自Erlang的方式。在Erlang中 所有的字符串都是字符列表。因为很多Elixir程序需要使用Erlang的库！
所有Elixir也提供把字符列表当字符串看待。

### 字符列表 比字符串 较慢 也占用更多的内存 。所以有可能不要作为第一选择。

为了创建字符列表，使用单引号代替双引号。
>
    iex(8)> x = 'ixir'
    'ixir'
    iex(9)> 'el' ++ 'ixir'
    'elixir'

连接操作 使用 ++  而不是字串串中的 <> 

可以使用 List.to_string/1 把字符列表转换为字符串 
逆向转换： String.to_char_list/1:
>
    iex(10)> List.to_string('elixir')
    "elixir"
    iex(11)> String.to_char_list("elixir")
    'elixir'    

只要不是同Erlang库交互的目的 ，你应该坚持使用string。

## String Sigils
Elixir 也提供了其他方式来创建字符串，字符列表，和正则表达式。

魔符 以~开始 
- s for binary string  用于二进制字符串
- c for character list 用于字符列表
- r  for regular expression 用于正则表达式
- w  （产生一个用空白符分割的字 列表）
如果字符时小写 通常会发生 串写和escaping 。如果是大写（S C R W） 原封不动如其所现。则不会发生interpolation和escaping
在字符后 你可以使用任何nonalphanumeric字符，不仅仅是双引号 来开始和结束字符串。

>
    iex(12)> pass_through = ~S"This is a {#msg}, sha said.\n this is only a {#msg}."
    "This is a {#msg}, sha said.\\n this is only a {#msg}."
    iex(13)> IO.puts(pass_through)
    This is a {#msg}, sha said.\n this is only a {#msg}.
    :ok
    iex(14)>

w和W 用于字列表 此魔符接受一个二进制字符串并将之分成有空白符分割的字符串串列表
>
    iex(14)> ~w/Elixir is great!/
    ["Elixir", "is", "great!"]
    iex(15)>    

也可以创建我们自己的魔符！

.

## 问人信息
许多Elixir程序 运行的像批发商一样 --  后台，提供商品 和服务 给直接和用户交互的retailer（分销商 零售商）
有时候有一个直接的接口（比IEx更客户化的命令行） 给代码更好。 
你可能不会写很多Elixir应用程序 其主要的接口就是一个命令行！ 但你会发现在你试验你代码时 这种接口很有用。

你可以混合input和output 同你的程序逻辑 ，但对这种类型的简单facade ，把他们放到一个独立的模块更有意义。

** erlang的io函数 用来处理input时 有一些奇怪的交互通erlang shell **

## 收集字符
IO.getn 函数 会让你从用户哪里得到一些字符。

这看起来应该像 你有一些选项列表，把这些选项展示给用户 并等待响应 。

~~~

    defmodule Ask do
        
        def chars() do
            IO.puts(
                """
                Which planemo are you on?
                1, Earch
                2. Moon
                3. Mars
                """
            )
            IO.getn("Which? ")
        end

    end
~~~

他们展示一个菜单  关键地方在IO.getn 调用。第一个参数是一个提示。第二个是你想返回的字符数 默认是1 。
此函数仍旧允许用户输入任何东西直到按enter 。 但只取第一个字符（或者参二指定的数目）

## 读取一行文本
erlang 提供了一些不同的函数，用来从用户请求信息。IO.gets等待用户输入一个完整的一行文本 结束于新行

~~~elixir

    defmodule Ask do
        def line() do
            planemo = get_planemo()
            distance  = get_distance()
            Drop.fall_velocity(planemo, distance)
        end

        defp get_planemo() do
            IO.puts("""
            Which planemo are you on?
            1. Earth
            2. Earth 's Moon
            3. Mars
            """
            )

            answer = IO.gets("Which ? > ")
            value = String.first(answer)
            char_to_planemo(value)            
        end

        defp get_distance() do
            input = IO.gets("How far (meters ) > ")
            value = String.strip(input)
            binary_to_integer(value)
        end

        defp char_to_planemo(char) do
            case char do
                "1" -> :earth 
                "2" -> :moon 
                "3" -> :mars 
            end
        end
    end
~~~






























































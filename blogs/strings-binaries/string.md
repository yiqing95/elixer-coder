
-  Strings 和 字符串字面量
-   字符列表 (单引号的字符字面量)
-   模式匹配和字符串处理

# 字符串字面量

-  单引号形式
-  双引号形式

内部表现形式不一样 ， 但有一些共性

+ 可以用UTf-8 字符
+ 可以包含转义字符
+ 允许插入 Elixir表达式 通过 语法 #{ ... }.
>   
        iex(13)> name = "yiqing"
        "yiqing"
        iex(14)> "Hello #{String.capitalize name}! "
        "Hello Yiqing! "
+  特殊语义的字符可以使用反斜杠转义
+  支持 heredocs

### Heredocs

~~~[elixir]

    iex(15)> IO.puts "start"
    start
    :ok
    iex(16)> IO.write "
    ...(16)> my
    ...(16)> string
    ...(16)> "
    
    my
    string
    :ok
    iex(17)> IO.puts "end"
    end
    :ok
~~~
heredoc 使用 三个 单引号 或者 双引号 

跟python 有点像哈！

~~~[elixir]
    
    IO.puts "start"
    
    IO.write """
    my
    string
    """
    IO.puts "end"

~~~

###　heredocs 大量用于为函数或者模块添加文档 

## sigils

同ruby一样 elixir 也有一些替换语法 来表达一些字面量
比如 **正则**  ~r{ ... }
在Elixir中 ~-style 字面量 被称为 sigils （一种具有魔力的符号）

sigil 开始于 ~ 跟一个 或大写或者小写的字符 ，一些有界的内容 ，或者一些选项
定界符包括： <...> , {...} ,[...] ,(...) ,|...| , /.../, "...", 以及决定sigil(魔术符号)类型的字符：

### 大写的字符串 后面的内容都是无转义跟解析的 小写的是带转义跟待解析的东西 
{interpolation 原意是：  插值  插值法  内插  内插法 } 意译感觉待解析比较好些


-  ~C 无转义以及interpolation的字符串列表
-  ~c 
-  ~R 正则式
-  ~r
-  ~S 无转义于解析的字符串 
-  ~s
-  ~W 
-  ~w 空白符分割的字 （words）

~~~[elixir]

    ~C[1\n2#{1+2}] 
    
    ~c"1\n2#{1+2}"
    
    ~S[1\n2#{1+2}]
    
    ~s/1\n2#{1+2}/
    
    ~W[the c#{'a'}t sat on the mat]
    
    ~w[the c#{'a'}t sat on the mat]
    


~~~
~W 和 ~w 魔术符可以携带额外的说明符（specifier ）
a c 或 s 其决定了返回结果 是 原子 ，列表 或者是字符组成的字符串

>
    iex(1)> ~W[the c#{'a'}t sat on the mat]a
    [:the, :"c\#{'a'}t", :sat, :on, :the, :mat]
    iex(2)> ~W[the c#{'a'}t sat on the mat]c
    ['the', 'c\#{\'a\'}t', 'sat', 'on', 'the', 'mat']
    iex(3)> ~W[the c#{'a'}t sat on the mat]s
    ["the", "c\#{'a'}t", "sat", "on", "the", "mat"]
    

定界符可以是任何非字的字符  如 ( { [ < 
    注意首尾配对即可 
    elixir 不检测嵌套定界符 ~s{a{b}  是三个字符的串 a{b
    
如果起始定界符 是三个 单引号或者双引号 此魔术符会以heredoc对待的

~~~[elixir]

    iex(4)> ~r"""
    ...(4)> hello
    ...(4)> """i
    ~r/hello\n/i
~~~
注意换行符号 \n

关于魔术符比较有意思的是 你可以自己定义呢！

## 关于名字"String"

在其他语言中 'cat' 和 "cat" 都是 **字符串**  

但Elixir 有自己的不同的惯例
>  只有双引号括起来的 是 strings  单引号括起来的是字符列表

这很重要 单引号跟双引号形式完全不同，库中 工作于字符串的库只是针对双引号形式

### 单引号形式的字符串 ----- 字符码的列表

单引号字符串形式表示为整数值列表，每个值对应字符串中的码点，因此我们说起是字符列表
~~~[elixir]
    
    iex(11)> str = 'yiqinng'
    'yiqinng'
    iex(12)> is_list str
    true
    iex(13)> length str
    7
    iex(14)> Enum.reverse str
    'gnniqiy'

~~~
iex 将其识别为列表，但将其值展示位字符串 这是因为iex将整数值列表打印为字符串 前提是每个值都是可打印字符
~~~

    iex(15)> [67,78,98]
    'CNb'
~~~
可看下内部表示
~~~
    
    iex(16)> str = 'wombat'
    'wombat'
    iex(17)> :io.format "~w~n" , [str]
    [119,111,109,98,97,116]
    :ok
    
    iex(18)> List.to_tuple str
    {119, 111, 109, 98, 97, 116}
    iex(19)> str ++ [0]
    [119, 111, 109, 98, 97, 116, 0]
~~~
~w 在模式字符串中强制其为erlang term ---即底层的整数列表 。~n是新行

最后的例子中 创建了新的列表 尾部时null字节 此时iex不在认为所有的字节都是可打印的了 所以现原形了！
如果字符列表中包含erlang认为不可打印的字符时  你就会看到列表的表示形式了！

因为字符列表是列表 所以列表操作 及 List 模块的函数对其有效
~~~[elixir]

    iex(22)> 'yi' ++ 'qing'
    'yiqing'
    
    iex(23)> 'yi' -- 'qing'
    'y'
    
    iex(24)> List.zip ['abc','123']
    [{97, 49}, {98, 50}, {99, 51}]
    
    
    iex(25)> [head | tail ] = 'cat'
    'cat'
    iex(26)> head
    99
    iex(27)> tail
    'at'
    
    iex(28)> [ head | tail ]
    'cat'
~~~


    
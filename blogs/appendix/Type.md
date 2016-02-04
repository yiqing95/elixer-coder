Type Specifications 和 Type Checking
==============

当我们看到 defcallback 看到了 参数类型和返回值类型
defcallback parse(uri_info :: UIR.Info.t ) :: URI.Info.t
defcallback default_port() :: integer
URI.Info.t 和 integer 是类型规范的例子。他们被Elixir语言自己实现  -- 不涉及特殊的解析 ，这个是示范Elixir元编程的威力的
很棒的例子。

## 实名时候规范被使用
Elixir 类型规范来自Erlang。在Erlang代码中看到导出的（public）函数前面有一行spec是很常见的事情的。这些元数据给出了类型信息。
下面的代码来自Elixir解析器(当前用Erlang写的)，
~~~

    -spec return_error(integer(), any() ) -> no_return().
    return_error(Line, Message) ->
        throw({error, {Line, ?MODULE, Message}}).
        
~~~
意思是return_error函数接受两个参数，一个是整数类型一个是任意类型，并且不返回（无返回值）。

Erlang用这种形式文档和他们的代码的一个原因是，你可以内联的方式在读源码时看到文档，你也可以在页面读到他们（一个文档工具
可以创建这些页面）

一个原因是他们有一个工具比如dialyzer 次攻击执行静态Erlang的源码分析，并报出某些失配的类型。

这些基本的益处可以作用于Eixir代码，我们有@spec模块属性 用来文档和函数的类型规范；在iex中我们有一个s帮助类用来显示规范 
还有一个t 函数用来显示用户定义的类型，我们也可以运行Erlang工具比如dialyzer在一遍又的Elixir .beam 文件上。

然而，目前类型规范在Elixir世界用的并不广泛。是否使用他们只是个人尝试的问题。

## 指定一个类型
一个类型在一个语言中只是所有可能值的一个子集。比如，type integer 意味着所有可能的整数值，但排除lists binaries PIDs 等。
在Elixir中的基本类型是： any, atom, char_list(单引号括起来的字符串)，float,fun ,integer, map, none, pid, port,reference,
以及 tuple 。

类型any(和其别名, _) 所所有值的集合，none是一个空集合。

字面原子或者整数是只包含那个值的集合。

值nil可被表示为 [] 或者 nil

## Collection Type 集合类型
列表被表示为 [type] ,其中type 是任何基本类型或者合成类型。这个标记法并没有强调是一个元素的列表 -- 他只是简单示出列表的元素
是那个类型而已。如果你想表示一个非空列表，使用[type, ...] 作为惯例 类型列表是 [any].的别名

二进制表示为下面的语法：
>   << >>

非空二进制(size 0)
> << _　: size >>

size bits 的序列，称之为字节字串 bitstring.
>   << _ : size * unit_size >>

zize units的序列，每个单位是unit_size字节长度。

最后的两个实例 size可以被指定为 _ ,此时二进制有任意bits/nits字节数。

预定义的类型 bitstring 等价为 **<<_::_>>** ,任意大小的字节序列，相似的 binary被定义为**<<_::_*8>>** 8位字节的任意序列。

Tuple元祖表示为 { type, type, ... } ,或者使用类型 tuple 所以 {atom, integer} 和元祖 tuple(atom, integer)表示一个元祖 其
第一个元素是一个原子 其第二个元素是一个整数。

## Combining Types 合并类型
范围符(..)可被用于字面整数 用来创建一个表示他们范围的类型，三个内建类型 non_neg_integer,pos_integer 和neg_integer 分别表示
大于或等于的整数 或者小于零。

union操作符| 指出可接受的值是参数的联合

在类型规范中括号可以用来归组项目。

## 类型和结构

和结是基本的map一样，你可以使用map类型，但这样做丢掉了很多有用的信息，推荐你为每个结构定义特定的类型。
~~~

    defmodule LineItem do
        defstruct sku: "", quantity: 1
        @type t :: %LineItem{sku: String.t, quantity: integer}
    end
~~~
你可以用LineItem.t 引用此类型。

## 匿名函数
匿名函数被指定使用(head -> return_type ) .
head指定了 函数的参数的类型，可以是... 意指任意数量任意类型的参数，或者是某个类型的列表，
(... -> integer )                                   # 任意参数；返回一个整数
(list(integer) -> integer)                          # 接受整数的列表并返回一个整数
(() -> String.t )                                   # 不接受参数返回一个Elixir字符串
(integer, atom -> list(atom) )                      # 接受一个整数和一个原子 并返回一个原子的列表

为了更清晰你可以在head部分用括号括起来
(atom, float -> list)
((atom, float) -> list )
(list(integer) -> integer)
((list(integer)) -> integer)

## 处理真值
类型 as_boolean(T) 指出实际匹配的值会是类型T，但使用此值的函数把他当成一个“真”值（任何东西只要不是nil或者false 就被认为
是true），这样对于Elixir函数 Enum.count的规范就是：
@spec count(t, (element -> as_boolean(term))) :: non_neg_integer

## 一些例子

integer | float

任何数字(Elixir对此有一个别名)
[ {atom, any} ]
list(atom, any)
键值对类别 两种形式一样

non_neg_integer | {:error, String.t}    
整数大于或者等于0，或者一个元祖包含 原子:error 和一个字符串

( integer, atom -> { :pair, atom, integer} )
匿名函数接受一个整数和一个元祖 并返回一个包含原子:pair,一个原子，和一个整数的元祖

<< _ :: _ * 4>>
4位的序列

## 定义新类型
属性@type可以用来定义新类型
@type type_name :: type_specification

Elixir 用此来预定义一些内置的类型和别名
>
    @type term             :: any
    @type binary           :: <<_::_*8>>
    @type bitstring        :: <<_::_*1>>
    @type boolean          :: false | true
    @type byte             :: 0..255
    @type char             :: 0..0x10ffff
    @type list             :: [ any ]
    @type list(t)          :: [ t ]
    @type number           :: integer | float
    @type module           :: atom
    @type mfa              :: {module, atom, byte}
    @type node             :: atom
    @type timeout          :: :infinity | non_neg_integer
    @type no_return        :: none

如同list入口条目所示，你可以在新的定义中参数化类型。只需要在左侧边使用一个或者多个标识符作为参数，

@type variant(type_name, type) = {:variant, type_name, type }
@spec create_string_tuple(:string,String.t) :: variant(:string, String.t)
同@type Elixir 有模块属性@typeep 和 @opaque ，语义和@type一样 也做的基本一样的事情，不同之处就在结果的可见性。

@typeep 定义一个类型 他对包含他的模块是局部的(local) ---  类型是私有的 。@opaque定义了一个类型其名称对模块外可知但其定义
不是。

## 函数和回调的规范
@spec 指定了函数的参数数目，类型和其返回值类型。它可以出现在定义函数的模块中的任何地方，但根据惯例它应该理解出现在函数
定义之前，跟随任何函数的文档。

我们已经看到语法：
@spec function_name( param1_type,... ) :: return_type

让我们看一些例子，这些来自内建的Dict模块
>
    @type     key         :: any
    @type     value       :: any
    @type     keys        :: [ key ]
    @type     t           :: tuple | list  # `t` 是集合的类型   
    
    @spec     values(t)   :: [ value ]                            # values 接受一个结合(元祖或者列表)返回值（任何）的列表
    @spec     size(t)     :: non_neg_integer                      # size 接受一个集合并返回一个整数(>=0)
     
    @spec   has_key?(t, key)   :: boolean                         # 接受一个key的集合和返回值 true或 false
    @spec   update(t,key,value, (value -> value)) :: t            # update接受一个集合，一个key 一个value 和一个映射一个
                                                                  #  值到一个值的函数 ，他返回一个（新）的集合。

对于有多个heads的函数(或者有默认值的)，你可以指定多个@spec属性，这个是一个来自Enum模块的例子:

>   
    @spec at(t, index) :: element | nil
    @spec at(t, index, default ) :: element | default
    def at(collection, n , default \\ nil ) when n >= 0 do
        ...
    end

Enum 模块已有许多使用as_boolean的例子：
>
    spec filter(t, (element -> as_boolean(term) )) :: list
    def filter(collection, fun ) when is_list(collection) do
        ...                                                                                                  
    
这时说filter接受某些enumerable和一个函数，那个函数映射一个元素到一个term(是any的别名)，filter函数对待那个值作为truthy，
filter返回一个列表。

想看更多的Elixir类型规范的信息，看看Kernel.Typespec 模块的问题吧。

## 使用Dialyzer
Dialyzer 运行在Erlang 虚拟机 其分析代码 ，查找可能潜在的错误。为了在Elixir中用它，我们必须将源码编译进.beam文件中并确保
debug_info 编译选项被设置(当运行mix默认时是开发模式)。让我们来看看如何做 通过创建一个有两个文件的小项目，我们也会移除掉
mix创建的supervisor，因为我们并不想把OTP拉进这个练习来。
~~~

    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/blogs/appendix/dailyzer (master)
    $ mix new simple
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/simple.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/simple_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd simple
        mix test
    
    Run "mix help" for more commands.
~~~
在想内部让我们创建一个简单的函数，偷懒起见，不实现body
~~~

    defmodule Simple do
        @type atom_list :: list(atom)
        @spec count_atoms(atom_list) :: non_neg_integer
        def count_atoms(list) do
            # ...
        end
    end
~~~

编译项目：
~~~

    $ mix compile
    lib/simple.ex:4: warning: variable list is unused
    Compiled lib/simple.ex
    Generated simple app
    
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/blogs/appendix/dailyzer/simple (master)
    $ dailyzer _build/dev/lib/s^Cple/ebin
~~~
Dailyzer 需要规范对你正在用的所有的运行时库。他存储它们到缓存中，它被称为持久化查找表（persistent lookup table 或者plt）
查找Elixir库：
>   iex(1)> :code.lib_dir(:elixir)
    'c:/Program Files (x86)/Elixir/lib/elixir'

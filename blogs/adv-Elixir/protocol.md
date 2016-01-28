inspect 函数返回一个任何值的可打印的表示 作为一个二级制( call strings)
停下了想下 ，Elixir如何实现的 ，  inspect接受任何东西 

他可以用guard clauses：
def inspect(value) when is_atom(value), do: ...
def inspect(value) when is_binary(value), do ...
    :  :
但有个更好的方式。
    
Elixir有个protocols的概念，一个协议有点想behaviours 在其中定义了必须被提供的函数来完成某事。
但行为对模块是内部的 --- 模块实现behaviour 。协议是不同的。-- 你可以把协议的实现完全放在模块的外部。这意味着你可以扩展
模块的功能 而不用对他添加代码 -- 实际上，你可以扩展模块的功能甚至不需要你拥有模块的源码！
    
# 定义一个协议
协议定义根基本的模块定义很像 ， 他们可以包含模块 - 和 方法基本的文档(@moduledoc 和 @doc)，他们可以包含一个或者多个函数
定义，然而这些函数没有body(函数体) --- 他们只是 协议需要的简单声明接口的地方。

如，下面是Inspect协议的定义
~~~
    
    defprotocol Inspect do
        def inspect(thing, opts)
    end
~~~

跟module一样，协议定义一个或者多个函数，但我们分别实现代码（实现代码独立的）

## 实现协议
defimpl 宏 让你为一个或者多个类型实现一个协议
~~~
    
    defimpl Inspect, for: PID do
        def inspect(pid, _opts) do
            "#PID" <> iolist_to_binary(pid_to_list(pid))
        end
    end
    
    defimpl Inspect, for: Reference do
        def inspect(ref, _opts) do
            '#Ref' ++ rest = :erlang.ref_to_list(ref)
            "#Reference" <> iolist_to_binary(rest)
        end
    end
~~~
最后 Kernel模块实现inspect,调用Inspect.inspect 随带他的参数。这意味着当你调用inspect(self) ,他变为调用 
Inspect.inspect(self) .因为self是一个PID ，这会被提取成类似"#PID<0.25.0>"样的东西。

在幕后，defimpl 把对每个 协议-类型 的组合 的实现放入各自模块中。对于Inspect的协议 针对PID类型是在模块Inspect.PID ,因为你可以
重新编译模块，你可以通过协议改变函数的实现

## 可用的类型
你可以定义实现一个或者多个下面的类型：
Any Atom BitString Float Integer
List PID Port RecordReference Tuple

类型BitString用来替换Binary 。

类型Any是一个通吃货 ，允许你用任何类型匹配一个实现。

你可以列出多个类型在一个defimpl中，比如，下面的协议可以被调用来决定一个类型是否是集合：
~~~

    defprotocol Collection do
        @fallback_to_any true
    
        def is_collection?(value)
    end
    
    defimpl Collection, for: [List, Tuple, BitString] do
        def is_collection?(_), do: true
    end
    
    defimpl Collection, for: Any do
        def is_collection?(_), do: false
    end
    
    Enum.each [1,1.0,[1,2], {1,2}, HashDict.new,"Cat"] ,fn value ->
        IO.puts "#{inspect value}: #{Collection.is_collection?(value)}"
    end
    
    iex(1)> c("is_collections.exs")
    1: false
    1.0: false
    [1, 2]: true
    {1, 2}: true
    #HashDict<[]>: false
    "Cat": true
    [Collection.Any, Collection.BitString, Collection.Tuple, Collection.List,
     Collection]

~~~

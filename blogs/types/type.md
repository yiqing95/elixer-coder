第一要义

原生数据类型不必跟其表达的类型一样 ！

如原始的Elixir 列表只是一个有序的值的序列 我们可以使用[ ... ]来创建一个列表，使用 | 来重构或者构造一个列表。

但有另一个层 ， Elixir 有一个List 模块！，它提供了一系列操作列表的函数 这些函数经常使用递归或者 | 来添加这些额外的功能

此时 看你如何理解这两种东西：
有认为：
>
    原生的list 跟List module是不同的，原生的list是一个实现，而List 模块添加了一层抽象 ，两者都实现了类型 但类型是不一样的
    比如 原生list 没有flatten函数
    
Maps 也是一种原生类型，同lists一样 在Elixir中也有一个更加丰富的模块与之相应。
    
Keyword 类型是一个Elixir模块但是作为了元祖的列表实现的 。
~~~[elixir]

        options = [
            {:width, 72},
            {:style, "light"},
            {:style, "print"},
        ]
        
~~~    
很明显上面的东西仍旧是一个列表 ，所有适合list的函数都对其适用 ，
>
    List.last options
    
    Keyword.get_values options , :style
    
但Elixir也给你带来了类似字典的功能。
>    iex> Keyword.get_values options , :style
     # ["light","print"]
     
     这很像动态OO语言中的 鸭子类型 
     Keyword 模块底层并没有任何原生数据类型 ，只是简单的假设其作用的任何值是一个列表 并且是特定的结构组成的
     
这意味着在Elixir中 集合api路子很野     
在处理关键字列表时 可以使用原生的List api ，或者List跟Keyword模块的api 。或者Enum 和Collectable模块
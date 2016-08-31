Elixir  程序基本都涉及消息请求 然后使用一些工具来处理这些请求 Elixir提供了一些工具简化并高效的处理这些消息 让你创建可读代码同时当你需要速度时
他们仍旧可以很高效。


## Atoms

atom是Elixir 的核心组件 技术上说 其只是另一种数据类型  但其对Elixir程序的风格影响很大。

以冒号做前缀的文本位（bits of text）
:this_isatom

>
        Atoms are a key component of Elixir. Technically they’re just another type of data, but
    it’s hard to overstate their impact on Elixir programming style.
    Usually, atoms are bits of text that start with a colon, like :ok or :earth or :Today. They
    can also contain underscores (_) and at symbols (@), like :this_is_a_short_sen
    tence or :me@home. If you want more freedom to use spaces, you can start with the
    colon, and then put them in single quotes, like :'Today is a good day'. Generally,
    the one-word lowercase form is easier to read.

atom的值就是其文本

~~~

    iex(12)> :atom                                                                                                                               
    :atom

~~~
atom 本身并不令人激动 。有趣的是他们可以和其他类型一起同Elixir 模式匹配技术来构建简单 但强大的逻辑构造。

## 用atom 做模式匹配

>
    def foo(:cond1 , p) do  ... end
    def foo(:cond2 , p) do  ... end
    def foo(:cond3 , p) do  ... end



## atomic booleans
true false 在elixir底层实际是atom :true :false  不过不需要使用冒号.
>
    iex(13)> :true == true                                                                                                              
    true                                                                                                                                
    iex(14)> :true == false                                                                                                             
    false                                                                                                                               
    iex(15)> :false == false                                                                                                            
    true

用于原子布尔 的操作符：
>
    iex(17)> true and false                                                                                                             
    false                                                                                                                               
    iex(18)> true or false                                                                                                              
    true                                                                                                                                
    iex(19)> false or false                                                                                                             
    false                                                                                                                               
    iex(20)> not true                                                                                                                   
    false                                                                                                                               
    iex(21)> not false                                                                                                                  
    true                  

注意 and 和 or 是短路的

这些逻辑操作如果作用对象不是 true false :true false 或者其计算结果为他们 那么会得到参数错误：
>
    iex(22)> not :any                                                                                                                   
    ** (ArgumentError) argument error                                                                                                   
        :erlang.not(:any)     

跟true 和false 一样  :nil nil 也是一样的
但另一些具有被接受意味的如 :ok 和 :error 是没有被特殊对待的（虽然他们也被广泛使用） 冒号是必须的。       

## 函数卫士 **guards**

函数接受什么样的数据 更精细化的过滤参数的内容 

Guard 必须简单 也可以使用少数的内置函数 并被限制为计算时无边缘效应 但他们仍旧可以transform你的代码。

guards 计算他们的表达式到 true 或者false 

>  def fall_velocity(:earth, distance ) when distance >= 0 do :math.sqrt(2 *　9.8 * distance)  end

when 表达式 在函数的头部 描述了一个条件或者 一些条件

由于这些护卫的出现 参数特征如果不符时 会报错 FunctionClauseError 

~~~Elixir


    defmodule Math_demo do
    
    def abs_val(num) when num < 0 do
        -num
    end

    def abs_val(num) when num == 0 do
       0
    end

    def abs_val(num) when num > 0 do
        num 
    end

    end
~~~

Elixir 运行函数子句的顺序跟其出现的顺序一致 一旦匹配就停止继续往下搜索了

当护卫子句 仅仅是测试一个值（参数）时 最好使用模式匹配而不是guard
比如上面的 == 0  
改为  >  def abs_val(0) do  0 end

## 不关心的变量 下划线前缀之
如果参数 在函数内没被用到 编译器会抱怨的-给你警告！（怀疑你是不是犯错了）==》 变量xx 未被使用
DO-END 结构
---------------

do end代码块 是组织表达式并将之传递给其他代码的一种方式

可用于 module 命名函数定义 控制结构 以及任何Elixir中 需要将代码段做为一个整体处理的地方！

然而 do ...end 并不是真正的底层语法 ， 真正的情况是

~~~[elixir]

    def double(n)  , do : n * 2

~~~

当多行时 可以用括号引起来

~~~[elixir]
    
    def greet(greeting,name) , do: (
        IO.puts  greeting
        IO.puts "How're you doing #{name} ?"
    )

~~~

do ... end 只不过是语法糖 底层会在编译期将之编译为 do:form .的形式的
一般我们用do:... 在单行情形 ，多行情形会采用  do ... end 形式

~~~[elixir]
   
    # module-test/times1.exs
     
    defmodule Times do 
        def double(n) , do: n*2

~~~

我们甚至可以这样定义一个模块：
>  defmodule MyModule, do: (def double(n),do: n*2 )

但劲量不要这么干！！！
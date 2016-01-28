Using Binding 注入值
------
有两种方法注入值到quoted blocks中 ，一种是unquote ，另一个是使用binding绑定。然而，这两个有不同的用法和不同的语义。

绑定只是简单的变量名称和其值的关键字列表，当我们传递绑定给quote时变量被设置进被quote的body体内。

这个很有用 因为宏在编译期被执行，这意味着他们不能访问运行期计算的值。

这儿有个例子，意图是让宏定义一个函数返回他自己的名字：
~~~
    
    defmacro mydef(name) do
        quote do
            def unquote(name)() , do: unquote(name)
        end 
    end
~~~
## Macros Are Hygienic

把宏想象为某种文本的替换 -- 宏 体 扩展为文本 之后在调用点编译。但实际情况不是这样的 。
~~~
    
    defmodule Scope do
        defmacro update_local(val) do
            local = "some value"
            result = quote do
                local = unquote(val)
                IO.puts "End of macro body , local=#{local}"
            end
            IO.puts "In macro definition, local = #{local}"
            result
        end
    end
    
    defmodule Test do
        require Scope
        local = 123
        Scope.update_local("cat")
        IO.puts "On return, local = #{local}"
    end
   
~~~



## 其他运行代码段的方法
我们可以使用Code.eval_quoted 来计算 代码片段 ，比如那些quote返回的
~~~
    
    iex(3)> fragment = quote do: IO.puts("hello")
    {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [], ["hello"]}
    iex(4)> Code.eval_quoted fragment
    hello
    {:ok, []}
~~~
默认情况，quoted片段是hygienic的 所以超出其域是无法访问变量的。使用 var!(:name),我们可以关闭这个特性并允许被quoted的块
访问变量在正在包含它域中
 ~~~
    
    iex(5)> fragment = quote do: IO.puts(var!(a))
    {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [],
     [{:var!, [context: Elixir, import: Kernel], [{:a, [], Elixir}]}]}
     
     iex(6)> Code.eval_quoted fragment, [a: "cat"]
     cat
     {:ok, [a: "cat"]}
 ~~~
 Code.string_to_quoted 转换包含代码的字符串到其quoted形式 ，Macro.to_string 转换代码片段到字符串。
 ~~~
    
    iex(7)> fragment = Code.string_to_quoted("defmodule A do def b(c) do c+1 end end ")
    {:ok,
     {:defmodule, [line: 1],
      [{:__aliases__, [counter: 0, line: 1], [:A]},
       [do: {:def, [line: 1],
         [{:b, [line: 1], [{:c, [line: 1], nil}]},
          [do: {:+, [line: 1], [{:c, [line: 1], nil}, 1]}]]}]]}}
 
     iex(8)> Macro.to_string(fragment)
     "{:ok, defmodule(A) do\n  def(b(c)) do\n    c + 1\n  end\nend}"
 ~~~
 我们也可以直接用Code.eval_string 来运行字符串
 >
    iex(9)> Code.eval_string("[a, a*b, c] ",[a: 2, b: 3, c: 4] )
    {[2, 6, 4], [a: 2, b: 3, c: 4]}
 
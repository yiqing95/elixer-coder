#  Moduel

模块为我们定义某结构提供了名空间，它们用来封装 宏，结构 ， 协议 ，或者其他模块 。

要访问这些模块内部的成员 ，外部访问者需要冠以模块名： Module.Xxx
模块内部成员间的访问 可以不用带前缀。


## 模块嵌套

模块内定义模块只是一种示例

~~~[elixir]
    
    defmodule Outer do
      @moduledoc false
    
      defmodule Inner do
          def inner_func do
            IO.puts  "hi this is a inner func inside the inner module "
          end
      end
    
      def outer_func do
          Inner.inner_func
      end
    
    end

~~~

实际上所有的模块都定义在最顶级别（Top Level） ， 当我们在一个模块内部定义另一个模块时Elixir简单的把外部的模块名作为前缀添加在
内部的模块名之前，之间用点“.” 相连 。 这意味着我们可以直接定义一嵌套模块：

~~~[elixir]

    defmodule Mix.Tasks.Doctest do
      @moduledoc false
    
      def run do
        IO.puts "hi here"
      end
    
    end
    
    Mix.Tasks.Doctest.run

~~~
也意味着Mix 跟 Mix.Tasks.Doctest 没有特殊关系

## 模块指令

-  语法域（lexically scoped ）
   
    开始声明  结束声明
    
-   import 
    
    将模块的方法 或者宏 导入到当前 域
    导入语法： import Module [, only:|except: ]
    
    此外也可以给only 一个原子 :function 或 :macros  此时也只会导入方法或者宏
    
-   alias
    
    别名指令 可以创建一个模块的别名 ，一个显著的用途是缩短拼写
    
    ~~~[elixir]
        
        defmodule Example do 
            def func do
                
                alias Mix.Tasks.Doctest , as: Doctest
                 
                doc = Doctest.setup
                
                doc.run(Doctest.defaults)
            
            
            end 
        
        end 
    
    
    ~~~
    
-   require 
    
    如果想使用一个模块中定义的宏我们会require一个模块的 。 确保指定的模块先于当前模块被加载，
    
    
## 模块属性
    
每个模块可以有关联的元数据，被称为模块的属性：  @attribute

可以给属性赋值：  @attr_name  <attr_value>  

属性定义只出现在最顶级，不能在函数级别这么做。但我们可以在函数中访问属性：

~~~<elixir>

    defmodule Example do
        @author "yiqing"
        
        def get_author do
            @author
        end 
    
    end 

    IO.puts "Example written by #{Example.get_author}"
~~~

属性可以多次定义 函数中可以访问他们：

~~~[elixir]

    @attr "one"
    
    def first , do: @attr
    
    @attr "two"
    
    def second , do: @attr

    # -------------------------------------------------------------------------------------------
    #输出
    # 多次定义的属性输出
    IO.puts " #{Example.first} #{Example.second} "
    
    # > 结果          one            two
~~~
这些属性不是一般意义上的变量，只用于配置或者元数据，Elixir程序员会使用他们 而这些属性出现的地方通常java或者ruby程序员会
使用常量的

## 模型名称： Elixir Erlang Atoms

我们访问模块的方法：
   
> ModuleName.mod_func("param")

实际在Elixir内部，模块名称只是atoms（原子）。
但我们写一个以大写字母开头的名称时，比如IO Elixir内部会将其转换为原子：Elixir.IO

>
     iex> is_atom IO                          # true
          to_string   IO                      # "Elixir.IO"
          :"Elixir.IO"  === IO                # true
          
实际上调用一个模块的方法 语法可以是： :atom_name.func_name(params ...)             
       
~~~[elixir]
       
       IO.puts 123
       # 等价下面的形式
       :"Elixir.IO".puts 123   # 123
       
~~~       

## 调用Erlang模块中的方法

名称在Erlang中的惯例是不同的：

- 变量以首字大写开始，
- 原子是简单的小写

使用timer模块的tc函数  

>  :timer.tc # 注意开始的冒号

调用Erlang模块的format函数

> :io.format("The number is ~3+

.1f~n " , [5.678])

如果寻找能够为我们所用的库时，先找是否有可用的Elixir模块，内置的可以在官网看到，其他的列在 http:hex.pm 或者在githu上搜索
**elixir**

如果还没找到 那么可以使用Erlang的内置模块 但请注意，Erlang 有其自己的命名惯例 ： 变量以首字大写开始，标识符小写开始（原子）。
其他不同处见于： [...](todo)




    
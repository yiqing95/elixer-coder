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
    
    to be continue ...
    
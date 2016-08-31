交互式shell下的 东西复用性不强

一般还是将函数定义在可编译的模块里面而不是shell中（shell  下的东西 玩完退出 即消失）模块是更正式的放程序的地方,提供我们
存储，封装，共享，管理代码的更有效的能力。

每个模块应该出现在他们自己的文件中，有一个.ex 扩展（当然一个文件中可以出现多个模块  但开始时 简单起见 最好一文件一个）
风格： name_of_module.ex
小写的蛇形命名

Drop模块 文件名称应该是 drop.ex

模块名称首字大写

虽然函数定义有一行版本如： def mps_to_mph(mps), do: 2.23693629 * mps
但为了一致性和可读性 ，推荐你使用使用 do ... end 语法来书写所有的函数。

## 公有函数
def  定义的函数 是模块的共有函数

## 私有
defp 定义的函数仅对模块内可见

## 编译

模块定义好后 在shell中编译 。在IEx 环境下可以使用 c 函数 （注意iex启动路径 跟模块路径在同一个目录下）
>
    iex(1)> c "drop.ex"
    [Drop]
    iex(2)>

模块编译后 就可以在代码中使用了 Mod.func() ...

当编译模块后 会在源文件目录下产生对应的beam文件  下次如果还要使用模块函数 就不需要编译了
使用iex 退出然后再次进入该目录 直接Mod.func()  就可以调用模块的函数了。

很多Elixir程序涉及到在模块中创建函数 并将他们连接起来形成更大的程序。

！ 再次提醒 可以在iex中使用 一些shell命令 比如 pwd  cd  来显式当前目录 和切换目录。

## 编译多个
如果你发现在IEx中 你自己不断的在重复自己 ，你也可以使用c 来“编译” 一系列的IEx 命令。 
将这些一系列的IEx 命令放到一个.exs (for Elixir script) 文件。 当对这个文件调用c函数，Elixir就会执行其中的
所有命令 。

当创建和交付Elixir程序是，我们将以一些编译的BEAM文件形式发布。 不必从shell下逐个编译他们。elxirc 命令会让我们自动直接编译
Elixir文件集合并合并这些编译后的东西到make 任务或类似的东西。在.exs 文件上调用 elixir 命令可以让我们在IEx外的环境下以脚本形式
运行Elixir代码。

## 从模块中 自由浮动函数（Free-Floating）

如果你喜欢fn允许的那种代码风格 ，但也想要代码在模块中存储的更可靠 更易于调试。可以兼有二者世界之长 通过使用& 捕获操作符来
引用我们已经定义的函数。

myShortFn = &Module_name.function_name/arity  

arity是函数的个数 。

之后就可以如此调用：
> myShortFn.()

## 分离代码到多个模块

关注点分离 

## 分离后的模块 如何协作

假设原先代码都在一个模块中 
关注点分离后  会分离出不同的模块  这些模块中会出现相互使用（依赖）

那我们可以像在IEx 中那样 先编译所有参与的模块
然后 找到一个主要模块的某个入口函数来调用启动整个逻辑。

假设是Main.main() ;
~~~

defmodule Main  do 
    def  main() do
    
        A.f1
        B.f2
        C.f3(D.f1)
        E.f |> F.foo

        ....    
    end
    ...
end
~~~

main函数的这个过程很像 在IEx中 来自己协调各个模块中函数的过程  
在脚本中 也是这种感觉 

## 可见性
Elixir 走了条于erlang完全背道而驰的事  除了显示声明的defp函数 其余的都是公开可以访问的！ eralng需要-export -import指令。



## 导入函数

import 会导入另一个模块中的东西到当下模块（如果是IEx 那也是一个特殊模块哦！） 这样可以减少不必要的模块前缀输入。

~~~elixir

    defmodule Combined do
        import Convert

        def  foo(p) do
            func_from_convert_mod( AnotherModule.some_func(p) )
        end

    end
~~~

import 会导入Convert 模块下的说有函数和宏（除了以下划线开始的），使用他们时不需要带模块前缀了。

导入erlang模块也一样
~~~~

    defmodule Mod_x do
        import :math
    end

~~~

导入整个某个模块下的东西可能会跟当前模块冲突 所以可以指定性导入：
> import :math, only: [sqrt: 1]    
除却性导入（排他）
> import :math, except: [sin: 1, cos:, 1]

谨慎使用import ， 它确实减少了你的输入 但导致你很难指出函数到底来自哪里。

## 参数的默认值

def foo_func(p1 , p2 \\ "defaultValue" ) do

end

## 文档化代码

文档是一等公民

单行注释 # this is single line comment ........

井号和行结束符endl 之间的东西被Elixie编译器忽略


文档:   @doc """ here document your function or module """

在你编译了带有doc注释的源码后 可以用h函数在IEx中显示这些关于函数的有用的信息
>
    iex(5)> c "drop.ex"                                                                             
    drop.ex:1: warning: redefining module Drop                                                      
    [Drop]                                                                                          
    iex(6)> h Drop.hello                                                                            
    * def hello()                                                                                   
                                                                                                    
    this is a demo function hello 

也就是 h方法 接受的参数如果是某个模块的函数时  会返回该函数上对应的doc 注释！

因为elixir 不是太关心类型 对于参数和返回值的 文档化返回 需要使用@spec 来指定 ，这看起来很怪 很像是对函数的重复定义
>   @spec func_name( type1() ) :: some_type()

之后就可以使用 s 函数来看其规范了
> s(Some_mod.some_func)

也可以使用 s(Mod_name)   来查看模块内所有的specs

常见的类型有 number() , integer() , float() ... 

## 文档化 模块
@moduledoc """  here  describe this module   , you can specify the creator ,functionality etc ... """

版本 @vsn 0.0.1

可以使用这些文档来创建web页 来总结模块和函数
可以使用ExDoc 工具 该工具可以识别Markdown 格式
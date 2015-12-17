OTP
============

OTP 代表 （Open Telegram Platform） 开放电文平台 提供了常用的解决方案

常常涉及： 应用发现 ， 错误探测和管理 ，热码切换 ，以及服务器结构 。

OTP早期是用来构造电话交换和交换机的。但这些设备跟我们想要的任何大型线上程序有着相似特征 。所以现在OTP成为了通用工具 用来
开发，管理大型系统 。

OTP实际是一个捆包 包括Erlang ，一个数据库（Mnesia），以及一个不可数的库集合 ，它也定义了你应用程序的结构 。和其他任何大型，复杂
框架类似 有着太多的内容去学习 。

我们其实一直在使用OTP -- mix ，Elixir编译器 ，但都是隐式使用 ，现在我们要显式用他们了.

## 一些OTP定义
OTP 使用应用层次这个术语来定义系统。一个应用程序由一个或者多个进程构成 。这些进程遵从OTP中的一些惯例 ，称为 behaviors
有一个行为被用于通用目的的服务器，其中的一个用于实现事件处理器 ，还有一个用于有限状态机 。这些行为的实现会运行在他们自己的进程中（
可能伴有辅助进程）。

有一个特殊的行为者 ，称为supervisor ，监控着这些进程的监控 并实现了重启策略（当进程需要时）

## OTP 服务器
许多服务器有着相似的需求集 。所以OTP提供了所有完成这些底层工作的库 。

当我们写一个OTP服务器时 ，我们设计一个模块 ，包含一个或者多个回调函数 这些函数有着标准的名称 ，OTP会在特定情形来调用合适
的回调的 。（调用合适的回调去处理特定情境） 。比如 ，当某人发送请求给我们的server。OTP会调用我们的handle_call 函数 ，传递
一个request ，调用者caller ，当前服务状态server state 。我们的函数通过返回一个元祖来响应他 ，元祖包括一个将会被采用的动作，
请求的返回值，和一个更新后的状态 。

### 状态和单服务器

回到我们计算列表总和的例子 ，我们遇到了一个accumulator（聚合器 累加器）的概念：
~~~
    
    defmodule MyList do
        def sum([] , total) , do: total
        def sum([head | tail ] ,total) , do: sum(tail , head+total)
    end 
~~~
参数total 在函数在列表中滚动（trundle down the list）时维护了状态

这些参数是用于状态信息的 。

现在想想我们的服务器， 他们使用递归去循环 ，在每次调用时处理一个请求 ，所以他们也可以在递归调用中用参数传递状态给他们自己。
这就是OTP为我们做的一件事情 。我们的处理器函数 获取到传递的当前状态（最后一个参数） ，之后返回一个可能被更改的状态（同其他东东一起）
。无论函数返回什么状态，他将被传给下一个请求处理器 。

## 我们第一个OTP 服务器

一个最简OTP server ， 当启动时你传递给他一个数字 ，他将变成当前服务器的当前状态 ，当你通过:next_number 请求来调用它时，
他会返回当前状态给调用者 ，与此同时 递增这个状态 ，为下次调用做准备 。基本上 每次你对他的调用你会得到一个更新的序列化数字。

~~~
    
    defmodule Sequence.Server do
      @moduledoc false
    
      use GenServer
    
      def handle_call(:next_number , _form , current_number) do
        { :reply , current_number , current_number+1 }
      end
    
    end

~~~
注意use 行  ， 为我们的模块添加了OTP GenServer 的行为 ，这将运行出来所有的回调，也意味着在我们的模块中不必定义每一个回调
-- 行为定义了默认的所有回调处理。

当一个客户端调用我们的服务器时 ， GenServer 调用 handle_call 函数，接受：
- 首参 客户端调用它传递的信息
- PID 客户端的pid作为次参
- 服务端状态作为末参 （第三个参数）

我们的实现很简单，我们返回一个元祖给OTP
{:reply , current_number, current_number+1 }
reply 元素告诉OTP 去reply给客户端 ，回传值是第二个元素 ，最后 元祖的第三个元素定义了新的状态， 这将被作为最后的参数传递
给handle_call 的下次调用。

~~~
    
    F:\Elixir-workspace\elixer-coder\projects\sequence>iex -S mix
    Eshell V7.0  (abort with ^G)
    Compiled lib/sequence.ex
    Compiled lib/sequence/server.ex
    Generated sequence app
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> {:ok , pid} = GenServer.start_link(Sequence.Server, 100)
    {:ok, #PID<0.101.0>}
    iex(2)> GenServer.call(pid , :next_number)
    100
    iex(3)> GenServer.call(pid , :next_number)
    101
    iex(4)> GenServer.call(pid , :next_number)
    102

~~~
我们使用了两个来自Elixir GenServer模块的函数 ，start_link 函数的行为很像以前的spawn_link函数 ，他请求GenServer来启动一个新
的进程，并连接到我们（因此如果它失败了我们会得到通知的），我们传递模块作为server来运行：初始状态是100 。我们也可以传递一个
GenServer选项作为第三个参数，但目前默认的就工作的很好了 。
我们得到一个状态 ，服务器PID ，call函数采用此PID并调用服务器的handle_call函数 ，call的第二个参数是作为传递给handle_call
的第一个参数。

我们可以定义多个版本的handle_call 来进行模式匹配 以处理不同的入参情形 。

如果我们想传递多于一个的东西在调用中给服务器，传递一个元祖即可 ， 我们的服务器可能需要一个函数来重设给定值的数量，我们
可以这样定义handler：
~~~

    def handle_call({:set_nuber , new_nuber} , _from , _current_number)  do
        {:reply , new_number,new_number }
    end 
    # call it with 
    iex> GenServer.call(pid , {:set_nuber , 999 })
~~~
类似的 ， 处理器也可以返回多个值 通过打包他们到元祖或者列表中 。

~~~
    
    def handle_call({:factors , number} , _, _ ) do
        {:reply , { :factors_of , number , factors(number) } , [] }
    end 

~~~

### 单向调用(one-way call)
call 函数调用一个服务器 并等待响应， 但有时候你并不想等待 因为没有响应返回， 此时使用GenServer 的cast 函数 （想成丢弃你
的请求到服务器之海中）

跟call传递到handle_call 函数一样 ,cast 会传递到 handle_cast ,因为没有响应 ，handle_cast 函数只接受两个参数 ：call参数和
当前状态  。  因为它也不发送响应 ， 它仅仅返回一个元祖 {:noreply , new_state } .

让我们修改我们的sequence 服务器 来支持 一个 :increment_nuber 函数 ， 我们将之认为是一个cast ，所以它简单的设置新状态并返回
~~~
    
    defmodule Sequence.Server do
      @moduledoc false
    
      use GenServer
    
      def handle_call(:next_number , _form , current_number) do
        { :reply , current_number , current_number+1 }
      end
    
     def handle_call({:set_nuber , new_nuber} , _from , _current_number)  do
            {:reply , new_number,new_number }
     end
    
    
        def handle_call({:factors , number} , _, _ ) do
            {:reply , { :factors_of , number , factors(number) } , [] }
        end
    
      def handle_cast({ :increment_number , delta } , current_nuber ) do
        { :noreply , current_number + delta } 
      end
    end

~~~
使用r 重新编译我们的服务器
~~~
    
    iex(5)> r Sequence.Server
    lib/sequence/server.ex:1: warning: redefining module Sequence.Server
    lib/sequence/server.ex:10: warning: variable new_nuber is unused
    lib/sequence/server.ex:19: warning: variable current_nuber is unused
    ** (CompileError) lib/sequence/server.ex:11: function new_number/0 undefined
        (stdlib) lists.erl:1337: :lists.foreach/2
        (stdlib) erl_eval.erl:669: :erl_eval.do_apply/6

~~~

即使重新编译了代码，老版本的依旧在运行 ，VM 并没有做热代码切换 直到你显式的用模块名称访问它 。
为了使用我们的新功能 ， 我们将创建一个新的服务器 ，当它启动时 他会选最近的代码版本的 ：
~~~
    iex> { :ok, pid } = GenServer.start_link(Sequence.Server, 100) 
    {:ok,#PID<0.60.0>} iex> GenServer.call(pid, :next_number) 100 
              iex> GenServer.call(pid, :next_number) 101    
           iex> GenServer.cast(pid, {:increment_number, 200}) :ok         
      iex> GenServer.call(pid, :next_number) 302 
~~~    

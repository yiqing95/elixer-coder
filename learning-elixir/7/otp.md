OTP
=======
OTP(开放报文平台 Open Telecom Platform) 是个框架 ，原先在Erlang早期作为Erlang的一部分，主要负责报文网络。
已经快速增长延展到通用目的的库 用来创建Erlang和 重要的Elixir程序。

OTP提供了一些基础的思想和原则用于我们的进程 指导我们驶向正确的方向。
包括OTP应用程序，（进程）supervision树，服务进程，事件进程和特殊进程。

## Applications 进程

许多Erlang/Elixir 中的概念都要警惕  可能跟以往理解不一样 ，比如 Erlang 进程 和 OS进程 就不一样。
同样，我们也要小心applications概念！

对于OTP，applications是自包含的进程树 服务于多种目的，或者甚至可以封装wrap多个（OTP）applications一起作为一个新的（super）
一个的进程。问题关于applications 如何 定义，开始，被管理典型地由进程supervision树来完成，但理解常规OTP应用这些细节并不是
必须的。

applications 和 OTP Applications 的差别是更上下文相关的

一个记号的OTP Application 的例子就是 用过多次的 iex 
>
    iex(5)> Process.list
    [#PID<0.0.0>, #PID<0.3.0>, #PID<0.6.0>, #PID<0.7.0>, #PID<0.9.0>, #PID<0.10.0>,
     #PID<0.11.0>, #PID<0.12.0>, #PID<0.13.0>, #PID<0.14.0>, #PID<0.15.0>,
     #PID<0.16.0>, #PID<0.17.0>, #PID<0.18.0>, #PID<0.19.0>, #PID<0.20.0>,
     #PID<0.21.0>, #PID<0.22.0>, #PID<0.23.0>, #PID<0.24.0>, #PID<0.25.0>,
     #PID<0.26.0>, #PID<0.27.0>, #PID<0.31.0>, #PID<0.34.0>, #PID<0.35.0>,
     #PID<0.36.0>, #PID<0.37.0>, #PID<0.38.0>, #PID<0.39.0>, #PID<0.40.0>,
     #PID<0.42.0>, #PID<0.43.0>, #PID<0.44.0>, #PID<0.45.0>, #PID<0.60.0>,
     #PID<0.61.0>, #PID<0.62.0>, #PID<0.63.0>, #PID<0.64.0>, #PID<0.65.0>,
     #PID<0.75.0>, #PID<0.76.0>, #PID<0.77.0>, #PID<0.78.0>, #PID<0.79.0>,
     #PID<0.80.0>, #PID<0.81.0>, #PID<0.82.0>, #PID<0.84.0>, ...]
    iex(6)>

Process.list/0  返回当前运行的进程列表。

这些都是不同的进程通过iex Application 绑定一起的。他们中的许多自己就是OTP applications ，
比如，我们可以看到 启动的 命名进程 当我们加载一个交互会话时：
>
    iex(6)> :application.which_applications
    [{:workpool, 'workpool', '0.0.1'}, {:logger, 'logger', '1.1.1'},
     {:mix, 'mix', '1.1.1'}, {:iex, 'iex', '1.1.1'}, {:elixir, 'elixir', '1.1.1'},
     {:compiler, 'ERTS  CXC 138 10', '6.0'}, {:stdlib, 'ERTS  CXC 138 10', '2.5'},
     {:kernel, 'ERTS  CXC 138 10', '4.0'}]
    iex(7)>

方法:application.which_applicaitons/0 的返回值被定义为{Application, Description, Vsn}
- 其中Application 是应用的名称 
- Description 是字符串形式的应用名称或者一个应用的解释文本
- Vsn 是被加载应用的版本。
【 什么叫被加载的应用？ Erlang虚拟机 有一个用于 热交换代码的方法，隐藏 ，可以跟踪已加载的模块版本变得很重要，所以
 **loaded** 版本是当前在内存中的应用版本（不必是最近的一个版本） 】
 
 总之，application 意为 一个单独的实体 工作于 操作 代码的单元/位 。代码单元本身可以是很多东西—— 一个API库 用于查询一个
 HTTP 端点(endpoint) , 一个分布式 key-value 存储，iex自身 ，或者任何你能想到或者开发的东西。
 
## Gen(eric) behaviours
当我们创建Elixir 应用 我们可以使用OTP定义的一些通用的行为。
有一个GenServer行为，GenEvent 和 :gen_fsm 行为。所有的这些行为有其基础 在一个更通用的OTP进程行为。

这些行为移除了一些我们不得不处理的冗繁的工作（比如消息处理，）

## Gen(eric) servers
OTP给了我们一个基本的进程蓝图 可以接收消息，处理消息并发送返回结果，同任何其他服务器那样。

**Gen** 在GenServer中实际代表的 generic 或者 general 因其提供了通用的细节 这样的进程以很灵活的解决方案 不用太多的限制其
用户。
比如我们看到 进程的主事件循环天性基本都类似； 真正的不同点在于 进程响应的消息 和 这些消息的处理。 大部分其他细节都一样。
这就是GenServer 行为 可提供给我们的。

作为一个快速开始的例子，我们重新创建我们的key-value store项目。
开始于任何GenServer模块代码骨架：
~~~

    defmodule KV do
      @moduledoc false
    
      use GenServer
    
      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, [], opts)
      end
    
      def init() do
        {:ok, HashDict.new}
      end
    end
~~~
为了创建一个GenServer 进程，我们定义了常规的Elixir模块。 然而，不像其他模块 我们在开始使用了 user GenServer 。这个告诉
Elixir 我们正在定义的模块将使用GenServer行为。

接下来 我们定义了一些 专用函数（行为要求的 类型实现某个接口 需要完成方法的实现）
>
    def start_link(opt \\ []) do
        GenServer.start_link(__MODULE__, [] , opts )
    end

功效等价 Process.spawn 或者 Process.spawn_link ,我们使用了来自GenServer模块的帮助函数来启动我们的进程。这个帮助函数会调用
我们的第二个函数，
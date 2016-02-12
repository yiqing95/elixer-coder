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
我们的第二个函数，init/1
>
    def init() do
        {:ok, HashDict.new}
    end
    
init/1 函数 会被调用来启动进程的状态 并确保初始状态正常。通常 只有一行 **{:ok, state}** ,其中state是进程的内部状态对象。
初始化为一个合适的状态，因为我们创建的是一个简单的key-value 存储。我们可以使用HashDict结构用于我们的进程状态。

元祖的第一个原子如果不是:ok 的任何其他值，进程就会拒绝启动。当上游依赖或者其他保障没到位时 这个就很有用了 在特殊情况下不
希望进程启动。

这个是最简单的骨架代码实现 ，不会太有用 因为我们没有定义其他的函数。

GenServer进程 有一些其他的方法用来处理消息 --  handle_call/3 和 handle_cast/3 . 这些函数的目的相似，但有不同的行为，更多
地 这些函数从不会被客户端代码直接调用。 他们只是在内部被OTP框架所调用。OTP框架管理内部的进程主循环 ，分派消息到我们的不同
版本的函数： handle_call/3 和 handle_cast/3 .

继续我们的key-value 例子，让我们定义我们的 handle_call/3 函数：
>
     ## 处理消息
      def handle_call({:put, key , value} , _from, dictionary) do
        {:reply, :ok, HashDict.put(dictionary, key, value)}
      end
    
      def handle_call({:get, key}, _from, dictionary) do
        {:reply, HashDict.get(dictionary, key), dictionary}
      end

函数handle_call/3  的第一个参数是一个消息元祖。典型地，我们有一个指定消息类型的原子 或者服务器应该执行的动作，
第二个参数（该例中不使用）是调用者进程。
第三个参数是进程的内部数据，在这种情况下，是我们会存入数据的字典。

第一个handle_call/2 模式匹配 一个元祖{:put, key, value } ，其中key 数据的键或者id  value 是实际被存储的数据。
第二个模式匹配 {:get, key} 其中key是要提取的数据的id或者键。

返回的元祖被OTP 框架消费，元祖的第一个元素通知OTP框架 如何处理响应。第二个元素是一个值 返回给调用者进程 。第三个是内部状态
被修改的，或者未改动的 用在下次消息接收中。
这跟我们手动写的很相似。

为了完整性，这里是迄今全部的模块代码：
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
    
      ## 处理消息
      def handle_call({:put, key , value} , _from, dictionary) do
        {:reply, :ok, HashDict.put(dictionary, key, value)}
      end
    
      def handle_call({:get, key}, _from, dictionary) do
        {:reply, HashDict.get(dictionary, key), dictionary}
      end
    
    end
~~~
自此，我们实际可用使用我们的进程 在交互会话中：
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\7\codes>iex
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> import_file "k_v.ex"
    {:module, KV,
     <<70, 79, 82, 49, 0, 0, 12, 64, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 2, 160, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:handle_call, 3}}
    iex(2)> {:ok, kv_pid} = KV.start_link
    {:ok, #PID<0.64.0>}
    iex(3)>

注意start_link/3函数 实际返回一个元祖, {:ok, pid} （和前几章那样 哪里只返回了PID 但这里 我们对PID还 返回了一个tag 
此tag 让调用者或者父进程知道开启或者子进程成功的启动了）  
  
现在，使用PID和GenServer.call/2 函数 ，我们可以发送消息给我们的key-value 进程：
>
    iex(3)> GenServer.call(kv_pid, {:put, :a, 42})
    :ok
    iex(4)> GenServer.call(kv_pid, {:get, :a})
    42
    
本地调用不成功!
>
    iex(2)> {:ok, kv_pid} = KV.start_link
    {:ok, #PID<0.80.0>}
    iex(3)> kv_pid
    #PID<0.80.0>
    iex(4)> GenServer.call(kv_pid, {:put, :a, 42})
    ** (EXIT from #PID<0.73.0>) an exception was raised:
        ** (FunctionClauseError) no function clause matching in HashDict.put/3
            (elixir) lib/hash_dict.ex:40: HashDict.put([], :a, 42)
            iex:16: KV.handle_call/3
            (stdlib) gen_server.erl:629: :gen_server.try_handle_call/4
            (stdlib) gen_server.erl:661: :gen_server.handle_msg/5
            (stdlib) proc_lib.erl:239: :proc_lib.init_p_do_apply/3
    
    
    08:13:39.795 [error] GenServer #PID<0.80.0> terminating
    ** (FunctionClauseError) no function clause matching in HashDict.put/3
        (elixir) lib/hash_dict.ex:40: HashDict.put([], :a, 42)
        iex:16: KV.handle_call/3
        (stdlib) gen_server.erl:629: :gen_server.try_handle_call/4
        (stdlib) gen_server.erl:661: :gen_server.handle_msg/5
        (stdlib) proc_lib.erl:239: :proc_lib.init_p_do_apply/3
    Last message: {:put, :a, 42}
    State: []
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> GenServer.call(kv_pid, {:put, :a, 42})
    ** (CompileError) iex:1: undefined function kv_pid/0
        (stdlib) lists.erl:1353: :lists.mapfoldl/3
    iex(1)>
    
但是 为什么 客户进程依赖使用GenServer.call/2 函数？ 这应该是一些 KV模块为客户做的事情。 这就是，我们可以定义更多的帮助函数
在KV模块中 这些函数会被调用 并发送正确的消息给客户端：


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
~~~

    def put(server, key, value) do
    GenServer.call(server, {:put, key, value})
    end
    def get(server, key) do
    GenServer.call(server, {:get, key})
    end
~~~
这两个方法就是在iex中的封装 我们只不过将其封装在KV模块中了。

重新加载 并启动KV进程 我们可以使用新的方法：
>
    iex(3)> KV.put(kv_pid, :a, 42)
    :ok
    iex(4)> KV.get(kv_pid, :a)
    42

我们创建的帮助方法可以做更多的事情； 如果我们知道只有一个进程实例时，我们可以在其启动时就注册。
>
    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, [], [name: __MODULE__] ++ opts )
    end
    
就是我们传递了[name: __MODULE__] 对，合并父进程传递过来的任何东西。通过提供:name 属性 在opts中，GenServer.start_link/3 
会注册进程在其启动后。此即意味着 我们不需要引用其PID。

在进程注册后，我们可以使用__MODULE__ 指令来应用注册的模块名称，即新版的KV模块代码如下：
>
    defmodule KV do
    use GenServer
    def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__] ++
    opts)
    end
    def init(_) do
    {:ok, HashDict.new}
    end
    def put(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
    end
    def get(key) do
    GenServer.call(__MODULE__, {:get, key})
    end
    def handle_call({:put, key, value}, _from, dictionary) do
    {:reply, :ok, HashDict.put(dictionary, key, value)}
    end
    def handle_call({:get, key}, _from, dictionary) do
    {:reply, HashDict.get(dictionary, key), dictionary}
    end
    end    

使用方法是一样的：
>
    iex(1)> import_file "kv.exs"
    {:module, KV,
    <<70, 79, 82, 49, 0, 0, 12, 152, 66, 69, 65, 77, 69, 120, 68, 99, 0,
    0, 2, 207, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95,
    100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 2, 104, 2, ...>>,
    {:handle_call, 3}}
    iex(2)> KV.start_link
    {:ok, #PID<0.76.0>}
    iex(3)> KV.put(:b, 42)
    :ok
    iex(4)> KV.get(:b)
    42
查看以注册的进程：
>
    iex(1)> Process.registered
    [:standard_error_sup, :kernel_safe_sup, :elixir_counter, Logger.Watcher, :rex,
     :erl_prim_loader, :elixir_config, :elixir_sup, :kernel_sup,
     :elixir_code_server, :global_name_server, :inet_db, :code_server,
     :file_server_2, IEx.Supervisor, Logger.Supervisor, :init,
     :application_controller, :user, Logger, :error_logger, :standard_error,
     :global_group, IEx.Config]

【不要被上面的名称愚弄 ，每个元素都是一个原子 ，试试： Process.registered |> Enum.at(n) |> is_atom ，其中 n 是列表中的
索引 ，返回结果应该是true 
>   iex(2)> KV.start_link
                    {:ok, #PID<0.90.0>}
                    iex(3)> KV in Process.registered
                    true
                    iex(4)>

】  
   
## Asynchronouse messageing 异步消息

看起来我们切换到OTP 使用GenServer后 没有了异步通信的能力 。即 GenServer.call/2 被阻塞了，同步调用，调用者进程必须等待响应


当创建GenServer 进程时  ，我们有另一些可用的函数 GenServer.cast/2 这个函数，不是阻塞的 ，把消息丢给GenServer进程后就立即
返回。

通GenServer.call/2|/3 版本类似 GenServer.cast/2 需要定义新的函数： handle_cast/2 。
~~~

    defmodule PingPong do
      @moduledoc false
      use GenServer
    
      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, [] , [name: __MODULE__ ] ++ opts)
      end
    
      def ping() do
        GenServer.cast(__MODULE__, {:ping, self() })
      end
    
      def handle_cast({:ping, from} , state) do
        send from, :pong
        {:noreplay, state}
      end
      
    end
~~~
init/1 函数仅当需要重新定义进程状态必须被初始化时才需要 ，不定义也没关系！
handle_cast/2 函数中 用模式匹配请求{:ping, from} 其中from是进程PID 
 
不像签名的handle_call/3 这里我们只返回了成功状态:noreply 和 状态 。没有直接返回给调用者进程 ，我们没有通道来使用
send/2 使用send函数时需要调用者进程的引用。
>
    iex(1)> import_file "ping_pong.exs"
    {:module, PingPong,
    <<70, 79, 82, 49, 0, 0, 11, 48, 66, 69, 65, 77, 69, 120, 68, 99, 0,
    0, 2, 124, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95,
    100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 2, 104, 2, ...>>,
    {:handle_cast, 2}}
    iex(2)> PingPong.start_link
    {:ok, #PID<0.82.0>}
    iex(3)> PingPong.ping
    :ok
    iex(4)> flush
    :pong
    :ok

我们在调用PingPong.ping/0 时没有接收到:pong 消息，当调用flush/0 时看到了，然而 注意 PingPong.ping/0 仍旧返回:ok 从GenServer
.cast/2 :
>   
    "This function returns :ok immediately, regardless of whether the destination node
    or server does exists, unless the server is specified as an atom."
    “这个函数立即返回:ok , 不管目标节点或者服务器是否存在，除非服务被指定为一个原子”
    
因为是异步调用 当你调用后 立即使用flush/0 可能在进程箱里面没有东西（还没到达） 为了展示这种情况 可以用:timer.sleep 5000
放在 handle_cast/2 函数中

## Gen(eric) events
发送消息给GenServer进程 很像发送事件 。GenServer收到一个tagged消息 对应执行某些动作 ，基于消息的输入和当前进程状态，进程
会计算某些结果，并执行一些动作。
然而执行复杂的逻辑 仍旧使人畏惧。

在OTP进程上下文中 ，GenEvent行为处理了很多问题 在开发一个基于事件的进程时。

GenEvent 行为 扮演一个事件分发器；它接受事件并重定向给处理器。 处理器（handler）在接收的事件上接管执行动作 。
在Elixir和OTP中 有很多这样的应用 和进程 模型 。
比如Elixir的Logging 模块就是一个GenEvent进程 ，重定向log事件到console或者任何额外的处理器 。

我们创建我们的第一个GenEvent 管理器使用 GenEvent.start_link/0 函数：
>
    iex(10)> {:ok, event_manager} = GenEvent.start_link
    {:ok, #PID<0.131.0>}
    iex(11)>

在穿件了我们的管理进程后，我们可以使用GenEvent.sync_notify/2 或者 GenEvent.notify/2 去给管理者进程发送事件:
>
    iex(10)> {:ok, event_manager} = GenEvent.start_link
    {:ok, #PID<0.131.0>}
    iex(11)> GenEvent.sync_notify(event_manager, :foo )
    :ok
    iex(12)> GenEvent.notify(event_manager, :bar)
    :ok

然而，因为event 管理器没有处理器(handlers) , 事件被丢弃了。 让我们定义 并添加一些基本的定向 处理器 ,接收事件并将之发送给
父进程。
>
    iex(13)> defmodule Forwarder do
    ...(13)> use GenEvent
    ...(13)> def handle_event(event, parent) do
    ...(13)>        send parent, event
    ...(13)>        {:ok, parent}
    ...(13)> end
    ...(13)> end
    {:module, Forwarder,
     <<70, 79, 82, 49, 0, 0, 9, 164, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 2, 44, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:handle_event, 2}}
    iex(14)> GenEvent.add_handler(event_manager, Forwarder, self())
    :ok
    iex(15)> GenEvent.sync_notify(event_manager, :ping)
    :ok
    iex(16)> flush
    :ping
    :ok
    
在处理器模块中，Forwarder， 我们定义了handle_event/2 函数用来接收事件。这个函数接收event和当前进程的状态变量，发送事件给
进程 并为OTP主循环返回{:ok, parent }
 
在定义了模糊后，我们添加它给处理器并发送其他的事件给管理器（manager）。

为了不打破单一职责原则，我们可以有更多的handler 做更多的事情对同一个事情。比如 让我们添加另一个处理器 打印消息到console:
>
    iex(17)> defmodule Echoer do
    ...(17)> use GenEvent
    ...(17)> def handle_event(event, [] ) do
    ...(17)>        IO.puts event
    ...(17)> {:ok, []}
    ...(17)> end
    ...(17)> end
    {:module, Echoer,
     <<70, 79, 82, 49, 0, 0, 9, 168, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 2, 44, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:handle_event, 2}}

这里我们定义了另一个处理器（跟前面的类似）,这里是把事件打印出来而不是发送给父进程。我们不需要跟踪任何内部状态，所以只是
传递了一个空列表。

在定义了处理器后 ，让我们将之添加到 event manager 并发送事件给manager ：
>
    iex(18)> GenEvent.add_handler(event_manager, Echoer, [])
    :ok
    iex(19)> GenEvent.sync_notify(event_manager, :hello)
    hello
    :ok
    iex(20)> flush

我们立即看到了消息打印到了控制台。刷新当前进程的收件箱 我们也看到了这些消息。
>
    iex(22)> GenEvent.notify(event_manager, :world)
    :ok
    world
    iex(23)> flush
    :world
    :ok
    iex(24)>

为了更好的演示异步发送事件的能力，我们 可以执行更多的工作 或者 人为的暂停其中一个处理器。试着添加:timer.sleep 给Echoer处
理器，然后试下 GenEvent.sync_notify/2 和 GenEvent.notify/2 .

## 特殊的OTP进程
我们当前覆盖的行为对我们开发的很多应用已经足够了。然而，我们如何受益于 supervision树 和 BEAM的（接近无限的）near-infinite
级别的跟踪能力 和debugging能力 。 更重要的接管OTP进程的主事件循环？

如果我们试图解决的任务并不能符合任何我们已经覆盖的OTP行为 ，仍旧有一种方法可以从OTP获取益处而不使用给定的行为。
这些在Erlang世界是只特殊的OTP进程 。对开发者有一些需求 ，如果可能 对特殊进程的使用应该避免。

不同于前面开发的进程，这些进程也会坚定OTP的设计原则并支持很多tracing和debugging设施 他们是OTP进程 和Erlang VM与生俱来的。
 
特殊进程模块的定义很像使用常规行为的模块。他们会有一个 start_link 函数，和init函数 ，和一些系统函数用来处理特殊的OTP消息。
作为一个简单的例子,让我们创建一个PingPong模块作为一个特殊的进程。

始于 start_link 函数：
>
    def start_link(opts \\ []) do
        :proc_lib.start_link(__MODULE__, :init, [self(), opts ])
    end

我们开始 链接当前模块使用init函数，传递parent和opts。
spawn_link/3 和Erang模块 proc_lib 中的start_link/3 的区别是 前者异步开始进程。后者涉及更多的控制
>
    def init(parent, opts) do
        debug = :sys.debug_options([])
        Process.link(parent)
        :proc_lib.init_ack(parent, {:ok, self() })
        Process.register(self(), __MODULE__ )
        state = HashDict.new
        loop(state, parent, debug)
    end

我们首先从:sys模块中创建了debug对象，此对象用来提取debugging信息；进程经常不会直接使用它的。

接下来，我们创建了一个链接到父进程 并调用init_ack，这告诉父进程 子进程已经起来在运行中。
...

最后，初始化状态字典 并调用loop函数传递状态字典，父进程引用，和debug对象。OTP设计原则需要这些 在进程的生存期内。
【loop 函数名称可以随意 ，在此上下文中 不算最坏的名字】
接下来，我们需要为我们的特殊进程定义 loop/3 函数
>
    defp loop(state, parent, debug) do
        receive do
            {:ping, from} ->
                send from , :pong
            {:system, from, request } ->
                :sys.handle_system_msg(request, from , parent, __MODULE__ , debug, state)
            end
            loop(state, parent, debug)    
    end
    
当进入到loop函数 进程会被阻塞，等待 :ping 消息或者 ;system 消息。:ping 消息是我们关心的。:system消息 是OTP消息需要的。
幸运的是我们可以使用:sys模块来处理:system  消息。然而 它也意味我们必须定义一些更多的函数  -- system_continue/3,
system_terminate/4, 和 system_get_state/1 这些函数比较琐碎：
>
    def system_continue(parent, debug , state ), do: loop(state, parent, debug)
    def system_terminate(reason, _, _, _): do, exit(reason)
    def system_get_state(state): do: {:ok, state}
    
这些不应该直接被用户或者客户调用，但对OTP 行为 仍旧需要是 public的 。

目前涉及的就是特殊OTP进程最小化的需求 。    
>
    iex(1)> import_file "pingpong_sp.exs"
    {:module, PingPong,
    <<70, 79, 82, 49, 0, 0, 11, 192, 66, 69, 65, 77, 69, 120, 68, 99, 0,
    0, 1, 212, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95,
    100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 2, 104, 2, ...>>,
    {:system_get_state, 1}}
    iex(2)> PingPong.start_link
    {:ok, #PID<0.79.0>}
    iex(3)> send PingPong, {:ping, self()}
    {:ping, #PID<0.60.0>}
    iex(4)> flush
    :pong
    :ok
    We are back to the API from the previous chapter; we lost our ability to use the Gen*
    functions for sending
    
我们失去了使用Gen* 系列方法帮我们发送消息给我们的进程 。我们可以添加一个函数 来抽象send/2 调用：
>
    def ping() do
        send __MODULE__ , {:ping, self() }
    end
    
## Gen* 进程中的变量域
当我们为我们的Gen*进程创建帮助函数时，我们需要明确这些函数运行的域 。 回忆前面的key-value 进程 ，当我们添加帮助函数：
put/2 和 get/1  这些函数是运行在calling进程的上下文的，而不是处理消息的服务进程中。

这即是 帮助者函数本身是永远不会访问当前服务器的状态，这样我们不能做其他额外的逻辑 。

## Back-pressure 和 load shedding
已经讨论了很多系统 使用同步和异步传输方法 ，GenServer 有call vs cast  GenEvent 有 sync_notify vs notify .在开发应用是，
倾向默认总是使用异步版本，因为他们更快，这确实是真的， 写文件到磁盘或者写数据到网络可能是很昂贵的；强迫上游进程等待这种处理
意味着客户或者用户可能也经历同步写的一样的等待。但我不支持这种引诱 ，应该先使用同步形式并profile你的系统和进程。之后如果
有保障了 在决定使用异步方法。通过使用同步变体方法，有自然的back-pressure 构建到系统（可以优雅降级？或者在同步和异步两种
方式间切换？）

另一种方法是使用异步行为，当有太多的消息需要发送时  但有一个机制切换API函数到同步行为 。这就是Elixir的内置Logging模块的确切
方式。
>   
    Building back-pressure or load shedding into a system will be a huge benefit to
    building a truly scalable application. Without it, limits will be found the hard way,
    users will be angry, stock holders will be equally upset, and business can be lost.
    Choosing either back-pressure or load balancing (or both) will help mitigate these
    issues. There will still be upset users, but the number of upset users will be orders of
    magnitude smaller than all of them.
>    
    Furthermore, using good end-to-end design and idempotent APIs will largely hide
    the issues and failures of back-pressure and load-shedding from the users and clients.
    
## Supervisors 
进程树

GNU/Linux 和 Unix-based OSes 是个存在的进程树极好的例子（可以学习 检阅）  它有一个根进程，典型地 init 从进程ID 1 开始。
是所有子进程的根（祖先）进程。每个孩子进程自身可以创建更多的孩子进程 ，这种链式结构时一个树（根是 PID 1）

Elixir/Erlang中的进程树不会太不相同，有一个根进程对运行时和应用控制器 。

OTP使用supervision树把进程树的概念带到了一个新的级别，Supervision树和进程树很像 除了它描述的稍许不同的概念。
进程树只描述了 进程间的parent-child 关系 ，而 supervisor树描述了 父子supervisors的类 对运行的进程和用于重启死亡孩子的策略。

最简单的supervisor树的例子是 一个supervisor监控一个进程 ，supervisor监听子进程的事件，并在特定事件上采取特定的动作 ，最基
础的就是什么都不做。这是基本的进程supervision假设。一个supervisor进程启动 或者重新启动子进程 在失败或者不正常退出时。

Supervisor自身时一个进程，所以自然的扩展就是 一个supervisor监控器有其他supervisors 这样 supervision树的概念就出现了。
更多的 一个supervisor有不同的重启策略对每个被监控的进程。

重启策略描述了 how 和 what 动作 一个supervisor会采取 当收到一个子进程死亡的通知时。OTP描述了四种不同的策略为我们：
one for one, one for all, rest for one 和简单的 one for one。

- one for one 描述的是 重启死亡进程。
- one for all 告诉supervisor 当一个进程死亡时 重启所有的进程（中间有杀死未亡进程的步骤哦！）
-  Rest for one 重启所有的进程 --- 从失败的到后面的 （进程的顺序 只启动失败点后面的rest的进程们）
- 简单的one for one 有点特殊，可能是四个策略中最复杂的
    处于simple one for one 下的进程 当supervisor启动时 经常不必静态的启动。内部的结构也不同于one for one
     one for one 存储子进程作为一个列表list ，而 simple one for one 存储在一个字典中 使得 simple one for one 对大量子进程
     管理时 更快。
     
随supervisor策略而来的对子进程或者工作者进程 还有重启选项。默认使用的重启选项是 :permanent ,即意味着进程 **总**被重启。
即使进程被正常杀死，比如：{:shutdown, :normal } , 对simple one for one 常用的选项是:temporary -- 表示进程 **never**被
重启。当supervisor 不是启动进程时很有用。比如连接池 每个进程都和一个连接关联 ，如果连接死掉 ，或者被重启 ，supervisor 监控
的进程不应该重启他们。第三个最后的选项用于resarts的是 :transient 意思是 supervisor只会启动非正常退出的进程 。就是 如果进程
关闭原因不是:normal, :shutdown,或者 {:shutdown, term} supervisor就会重启进程。



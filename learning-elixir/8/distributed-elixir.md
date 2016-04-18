分布式Elixir -- 并发带给另一个节点
============

普遍地，当我们想在不同的计算机上运行代码，我们必须要写特殊程序来处理节点间的代码加载和数据发送。此进程本身是很容易出错
并很难使之正确的。

然而在，Elixir和OTP中，代码在多个机器加载和互操作这样的困难工作已经帮我们做掉了。OTP框架会加载代码，连接节点，并处理分布式
应用的任务。

OTP不会做所有的工作，但给了我们很多工具帮助指导我们正确的方向，并帮我们做出正确的决定|选择。

>
    分布式计算很难
                                                                                                   -  每个人
                                                                                                   
## 分布式计算的骗局

通过理解分布式计算的8个（假的）假设 来理解Elixir和OTp如何做假设。

### 网络是可靠的

实际上 很不可靠。

各种原因都能导致失败 -- 切断了 ， 电压过高 ，常规的硬件失败 ，

不幸的是 OTP和Elixir没有任何特殊特征能够解决这种问题，因为 如何解决远程资源失效 这经常是一个应用特定的决策 。然而， 我们
通过使用异步的消息传递模型确实获取了可伸缩性。我们以同本地 进程内 一样的方式 处理远程资源的失效。这样，应用可用在性能和
设计上可水平扩展。

### 没有延迟

地理位置分离的环境。
本地调用 远程调用 逻辑上 相同对待 实际不一样
  
分离进程，超时，异步消息，和总是期望进程失败的语义 是OTP和Elixir能够再次指导我们向正确方向前进  。
然而我们必须小心超时阈值太低（很接近无延迟的假设）。

### 带宽是无限的
packet size

再次幸运 ，OTP和Elixir的设计和语义将帮助我们保持消息数小 ，另一个对于小消息的很好的trick是发送事件 而不是整个对象。

### 网络是安全的

用户输入时安全的 ，无恶意的 

### 拓扑结构不会变

硬件失败 升级 回收  添加 或移除 

幸运的是 在OTP中有些机制允许我们在开始时就忘掉拓扑结构。消息传递的进程可以忽略那个节点正在运行，对待错误也是一样的。

### 只有一个管理员

依赖第三方远程资源

###  传输代价是零


### 网络是同构的

OTP协议是完全开放的，任何节点实现了此协议都可以加入到网络，如果走路像个鸭子 ，叫声像个鸭子，就认为他是个鸭子。这允许C 互
操作，或者 C-nodes
【 一个 C-node 只是一个C程序 他实现了OTP协议 并变为OTP集群中的一个成员节点】

## 拿个黄油刀，盲目地战恶龙
构建分布式系统是很难的，即便有OTP和Elixir也仍旧很难。然而 有了OTP 我们就不会盲目 黄油刀也能变为剑 但我们仍旧要战恶龙。

仍旧有很多挑战，但至少我们有一些很好的工具。
很多问题变为应用层的设计决策

## CAP

## 网络拓扑

一个全连接的拓扑被称为crossbar或者switch。OTP 就使用了crossbar拓扑来连接节点。（通讯代价稍高）

## Elixir 分布式计算

## OTP 节点
OTP术语中的节点 是只一个Erlang虚拟机。只要资源允许 单个机器上可以有任意多个OTP节点 。 同一个网络中的OTP节点们也可以跨多个
机器。OTP节点甚至可以是地理位置分布的 但不太推荐。

如何分布OTP节点的选择经常是一个应用的选择。

## 节点名称

DNS

节点有长名称和短名称 。
长名称是节点的标识符和主机的FQDN（fully qualified domain name）。短名称相似 支部或主机标识符部分简单的是主机名称 。
>
    iex(1)> Node.self
    :nonode@nohost
    
Node 模块 提供了一些函数用来 工作于OTP节点和inspection
Node.self/0 函数提供了查看当前节点标识符 原子 的手段。 开始一个iex时如果不传递任何选项 那么就不会命名这个开启的节点。
这样就使之不可定位 。
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\7\codes>iex --name my_node@my_host
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(my_node@my_host)1> Node.self
    :my_node@my_host
    iex(my_node@my_host)2>
    
相似地 指定短名称：
>   
    F:\Elixir-workspace\elixer-coder\learning-elixir\7\codes>iex --sname yiqing_node
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(yiqing_node@yiqing)1>
    
短名称中的主机部分 会查询当前机器的host的 当然你也可以在--sname 中指定主机名    
    
## 连接节点
如果节点不互连，给其命名就没什么意义。

Node.list/0 列举互联的节点：
>   
    iex(yiqing_node@yiqing)1> Node.list
    []

开始两个iex实例
>
        
    C:\Users\Lenovo>iex --sname node_one
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(node_one@yiqing)1>
另一个
>
    C:\Users\Lenovo>iex --sname node_two
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(node_two@yiqing)1>
            
Node.connect/1 函数可用来连接节点 ，参数是节点的原子
>
    iex(node_one@yiqing)1> Node.connect :node_two@yiqing
    true
    iex(node_one@yiqing)2> Node.list
    [:node_two@yiqing]
    iex(node_one@yiqing)3>

我们在节点一种连接了节点2 在节点2 iex会话中：
>
    iex(node_two@yiqing)1> Node.list
    [:node_one@yiqing]

表示互连成功 。    


## Cookies 和节点安全
在OTP中两个节点的连接（或者断开连接）的基本保护就是通过Erlang cookie解决。cookie文件 .erlang_cookie 典型地写到当前用户的
home目录，
IEx 有一个 --cookie 命令行参数 允许复写cookie 
Node模块也有一个方法可以查看，设置cookie
>
    iex(node_one@yiqing)3> Node.get_cookie
    :FLVWSOCPNUUHOKZIHQND
    iex(node_one@yiqing)4> Node.set_cookie :anewcookie
    true
    iex(node_one@yiqing)5> Node.get_cookie
    :anewcookie
    
重连失败：
>   
    C:\Users\Lenovo>iex --sname node_3
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(node_3@yiqing)1> Node.connect :node_one@yiqing
    false
    iex(node_3@yiqing)2> Node.get_cookie
    :FLVWSOCPNUUHOKZIHQND
    iex(node_3@yiqing)3> Node.set_cookie :anewcookie
    true
    iex(node_3@yiqing)4> Node.connect :node_one@yiqing
    true
    iex(node_3@yiqing)5>
    15:41:34.323 [error] ** Connection attempt from disallowed node :node_two@yiqing **
    
把所有的会话cookie都设置一样后 就可以互连了：
>
    iex(node_two@yiqing)3> Node.set_cookie :anewcookie
    true
    iex(node_two@yiqing)4> Node.connect :node_one@yiqing
    true
    iex(node_two@yiqing)5> Node.list
    [:node_one@yiqing]

>   iex(node_3@yiqing)5> Node.connect :node_one@yiqing
    true
    iex(node_3@yiqing)6> Node.list
    [:node_one@yiqing]
    iex(node_3@yiqing)7> Node.connect :node_two@yiqing
    true
    iex(node_3@yiqing)8> Node.list
    [:node_one@yiqing, :node_two@yiqing]
    iex(node_3@yiqing)9>

公网上这样互连是不安全的 应为cookie文件会被嗅探的（可读的纯文本文件而已）。

##　Node　ping pong


一旦两个节点互连 我们就可以创建一个更“大”版本的 ping pong 程序
>
        
    iex(node_one@yiqing)6> pid = Node.spawn_link :node_two@yiqing, fn ->
    ...(node_one@yiqing)6> receive do
    ...(node_one@yiqing)6> {:ping, client} -> send client, :pong
    ...(node_one@yiqing)6> end
    ...(node_one@yiqing)6> end
    #PID<9002.100.0>
    
Node.spawn_link 函数 和我们先前见到的spawn_link 很像 。然而Node版的能偶在远程节点上启动一个进程！   
>   iex(node_one@yiqing)7> send pid , {:ping, self}
    {:ping, #PID<0.63.0>}
    iex(node_one@yiqing)8> flush
    :pong
    :ok
    
发送消息给进程 并刷新 ，我们接收到了原子消息 ，如我们所料的一样。
    
## Group leader 组长

当创建多节点的Elixir应用时 ，控制台往哪输出呢？log消息显示到哪个交互会话呢？

OTP I/O 系统使用 **group leader** 的概念来决定输出应该到哪里。这个组长就是处理一组Erlang进程的I/O 任务的进程 。除非修改
组长继承自父进程。

如果我们使用IO.puts/1 在你任一终端上，输出是导向当前终端的:
>
    iex(node_one@yiqing)9> IO.puts "hello world"
    hello world
    :ok
>    
    iex(node_3@yiqing)9> IO.puts "hello world"
    hello world
    :ok
    
然而 如果我们从node_one 在node_two上 派生一个进程 ,那么IO.puts的输出会被定向到node_one 的标准输出流的：
>
    iex(node_one@yiqing)6> Node.spawn :node_two@yiqing, fn -> IO.puts "hello world" end
    hello world
    #PID<9059.105.0>
    
输出虽然在本地，但进程运行在另一个节点。
    
为了让这个更明显 稍微修改下派生的进程：
>
    iex(node_two@yiqing)7> Node.spawn :node_one@yiqing, fn ->
    ...(node_two@yiqing)7> IO.inspect Node.self
    ...(node_two@yiqing)7> end
    #PID<9031.82.0>
    iex(node_two@yiqing)8> :node_one@yiqing
    iex(node_two@yiqing)8>
    
从node_two 启动了进程在Node_one ，Node.self/0 应该汇报的是当前节点 。所以输出是node_one 的原子： :node_one@yiqing

尽管进程运行在另一个节点但任何log日志或者I/O的输出都重定向到当前的组长进程中。

我们也可以使用进程组长 来作为I/O进程 用于从另一个节点写 。比如两个互连的节点，我们可以使用IO.puts/2 函数来重定向输出
>
    iex(node_two@yiqing)8> :global.register_name(:two, :erlang.group_leader)
    :yes

这个在节点间注册了进程名称 ；之后从节点一 我们可以提取 node_two 的组长的 进程ID
>
    iex(node_one@yiqing)7> two = :global.whereis_name :two
    #PID<9059.9.0>
    iex(node_one@yiqing)8> IO.puts(two, "Hello")
    :ok
    iex(node_one@yiqing)9> IO.puts(two, "World")
    :ok

然后在节点2 看到输出：
>
    iex(node_two@yiqing)9> Hello
    iex(node_two@yiqing)9> World
    
## 全局注册名称

前面我们曾注册过进程 这样可以通过原子而不是进程PID来引用进程。然而 对于互连的节点这是不够的，注册的进程只局限在当前节点了
并不对外共享。然而有一种机制可用于注册进程 这样 **每个** 互连中的节点都可以访问

如果我们在一个节点上派生了一个进程 ，ping pong 进程 或者过滤器进程 ，我们想从另一个节点上使用这些进程:
>
    iex(node_one@yiqing)12> pid = spawn_link fn() ->
    ...(node_one@yiqing)12> receive do
    ...(node_one@yiqing)12> {:ping, sender} -> send sender, :pong
    ...(node_one@yiqing)12> end
    ...(node_one@yiqing)12> end
    #PID<0.98.0>
    iex(node_one@yiqing)13> :global.register_name(PingPong, pid)
    :yes
    
在节点一 node_one 上，我们开启了一个最简单的 ping pong 接收循环。最后使用Erlang 的 :global 模块来以PingPong做原子全局性
的注册了进程。接下来 我们可以我们可以在node_two中发送消息给ping pong进程 并接收结果。
然而 全局名称不能替代掉PID引用 。 PID需要被查找 通过使用:global.whereis_name/1 函数：
>
    iex(node_two@yiqing)9> :global.whereis_name PingPong
    #PID<9031.98.0>
    iex(node_two@yiqing)10> :global.whereis_name(PingPong) |>
    ...(node_two@yiqing)10> send {:ping, self}
    {:ping, #PID<0.63.0>}
    iex(node_two@yiqing)11> flush
    :pong
    :ok

这运行我们消费运行在node_one 上的ping pong 进程 从node_two 使用一个原子即可。

另一个全局注册进程的例子，我们可以创建一个filter服务 GenServer 进程 它可以被来自集群的任何节点上所消费.
我们像平常那样创建FilterService 模块，
>
    defmodule FilterService do
        use GenServer
    
        def start_link(opts \\ []) do
            GenServer.start_link(__MODULE__, nil , [name: {:global, __MODULE__}] ++ opts)
        end
    
        def init(_)  do
            {:ok, %{} }
        end
    
        def filter(collection, predicate) do
            pid = :global.whereis_name __MODULE__
            GenServer.cast(pid, {:filter, collection, predicate, self})
        end
    
        def handle_cast({:filter, collection, predicate, sender}, state) do
            send sender, {:filter_results, collection |> Enum.filter(predicate) }
            {:noreply, state}
        end
    end


    

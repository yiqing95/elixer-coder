Nodes --  分布式服务的核心
===========
节点没有什么可神秘的 。只是一个运行着的Erlang虚拟机 ，

Erlang 虚拟机称之为 beam ， 更像是个简单的解析器 。像一个运行在主操作系统上的小操作系统 。处理它自己的事件 ，进程调度，内存
，名空间 和进程间通讯 。除了所有的这些 ，一个node 还可以连接到其他位于同一台机器，穿过lan 或者穿过internet的其他nodes 。 

## Naming Nodes
询问我们的Node名称
>
    iex(1)> Node.self
    :nonode@nohost
    iex(2)>
    
可以在iex启动时用--name 或者--sname 选项给我们的node一个名字    前者设置全称名称 后者短名称
>
    F:\Elixir-workspace\elixer-coder\spawn>iex --name yiqing@qq.local
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(yiqing@qq.local)1> Node.self
    :"yiqing@qq.local"
    iex(yiqing@qq.local)2>
    
>
    F:\Elixir-workspace\elixer-coder\spawn>iex --sname qing
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(qing@yiqing)1> Node.self
    :qing@yiqing
    iex(qing@yiqing)2>

注意机器名称是：yiqing

### 连接node
开两个终端命令行程序 
~~~
    
    C:\Users\Lenovo>iex --sname yiqing2
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(yiqing2@yiqing)1> Node.list
    []
    iex(yiqing2@yiqing)2> Node.connect :"yiqing@yiqing"
    false
    iex(yiqing2@yiqing)3> Node.connect :"qing@yiqing"
    true
    iex(yiqing2@yiqing)4> Node.list
    [:qing@yiqing]
    iex(yiqing2@yiqing)5>

~~~
终端1 上此时也看到了另一个连接的node了！
~~~
    
    iex(qing@yiqing)1> Node.self
    :qing@yiqing
    iex(qing@yiqing)2> Node.list
    [:yiqing2@yiqing]
    
    iex(qing@yiqing)2> Node.list
    [:yiqing2@yiqing]
    iex(qing@yiqing)3> func = fn -> IO.inspect Node.self end
    #Function<20.54118792/0 in :erl_eval.expr/5>
    iex(qing@yiqing)4> spawn(func)
    #PID<0.71.0>
    :qing@yiqing
    iex(qing@yiqing)5>

~~~
spawn函数允许我们指定节点的名称
~~~
    
    iex(qing@yiqing)5> Node.spawn(:"yiqing2@yiqing"  , func)
    #PID<9092.76.0>
    iex(qing@yiqing)6> :yiqing2@yiqing
    iex(qing@yiqing)6> Node.spawn(:"qing@yiqing"  , func)
    #PID<0.74.0>
    :qing@yiqing

~~~
spawn函数返回两个值 第一个是当前的 PID  第二个是func函数的输出（有点类似 js中的 call 方法可以绑定this）

注意输出都输出到一个控制台了，
代码虽然运行在node2上 但node一创建了他 ，所以它从节点一继承进程层次 。这被称之为group leader 这决定了IO.puts 的输出地
    
最终过程是这样的：我们启动了一个节点，运行一个进程在节点2上 ，之后进程输出一些东西 ，这些输出出现回节点1了 。
    
### Nodes Cookies and Security
尽管这个功能看起来很酷 ，但也响起了警钟 ，如果你能在任意节点运行任何代码 ，那么黑客可能控制任何一个可公共访问的节点。
但实际不是这样的，在一个节点允许其他节点被连接前，他会检测远程节点是否有权限，通过对比远程节点和本身节点的cookie。cookie
只是一个字符串而已（很长并很随机），作为一个Elixir分布式系统的管理员 ，你需要创建cookie并确保每个节点都使用了他 。
如果使用iex或者elixir命令行可以用个--cookie选项来传递cookie
>
   C:\Users\Lenovo>iex --sname one --cookie chocalate-chip
   Eshell V7.0  (abort with ^G)
   Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
   iex(one@yiqing)1> Node.get_cookie
   :"chocalate-chip"
   iex(one@yiqing)2>

另一个node：
>
        
    C:\Users\Lenovo>iex --sname node_two --cookie cookie-two
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(node_two@yiqing)1>
      
然后在第一个cmd窗口连接第二个：
>   
    iex(one@yiqing)2> Node.connect :"node_two@yiqing"
    false
    iex(one@yiqing)3>
发现没有连接上 第二个窗体此时也给出连接意向不允许的错误
>
    07:49:14.118 [error] ** Connection attempt from disallowed node :one@yiqing **
    
    iex(node_two@yiqing)1>

但为什么不指定cookie时连接是成功的？当Erlang启动时，他会查看一个.erlang.cookie文件在你的home命令 。如果不存在Erlang会创建他，
并存储一个随机串在文件中，他会 为用户启动的任何节点 使用这个串作为cookie ，那样你在特定机器上启动的所有节点将自动的给予彼此访问
权限。

但请注意通过公网连接节点时--  cookie是明文传递的！

## 为进程命名
尽管PID显示为3位数字，但其只含两个域，第一位是node ID 下一位是两位数的数字是低位和高位字的 进程ID 。当你在当前节点运行一个进程
时，其节点ID总是0 ，然而 当你把PID导出给其他节点时 ，节点ID被设置为那个进程寄居的节点序号。

回调识别的问题

如果你你想在一个节点上注册一个回调进程 并且在另一个进程上生成事件  只需要给事件生成器一个回调PID
但回调如何如何在初次找到生成器 ，一个方法是为generator注册器PID 给他一个名称 ，在其他节点的会带哦通过名称来查找生成器，
使用PID 发送消息

~~~
    defmodule Ticker do
    
        @interval 2000 # 2 seconds
        @name     :ticker
    
        def start do
            pid = spawn(__MODULE__ , :generator , [[]])
            :global.register_name(@name , pid )
    
        end
    
        def register(client_pid) do
            send :global.whereis_name(@name) ,{:register , client_pid }
        end
    
        def generator(clients) do
            receive do
                {:register , pid  } ->
                    IO.puts "registering #{inspect pid}"
                    generator([pid|clients])
            after
                @interval ->
                    IO.puts "tick"
                    Enum.each clients , fn client ->
                        send client ,{ :tick }
                     end
                generator(clients) # 等待注册或者超时两秒后发送心跳给所有已经注册的进程
            end
        end
    end
    

~~~

~~~
    
    defmodule Client do
        def start do
            pid = spawn(__MODULE__ , :receiver , [])
            Ticker.register(pid)
        end
    
        def receiver do
            receive do
                {:tick} ->
                IO.puts "tock in client"
                reciever
    
                end
        end
    end

~~~
### 何时 为进程命名
当你命名某物时，你就正在极力某种全局状态，如我们所知，全局状态会一起麻烦的，如果两个进程试图注册同意一名称呢？


## I/O PIDs Nodes
输入输出在erlang虚拟机中是使用I/O服务执行的 。这是些实现低级别消息接口的 简单的erlang进程 ，你几乎不用直面他们（这很好，因为
他们很复杂）。我们只是使用Elixir或者Erlang的 IO库去做这些琐重之事 。

在Elixir中我们通过I/O server的 PID标识一个打开的文件或者设备 ，这些PIDs行为跟所有其他的PIDs一样--- 你可以 比如 在nodes间
发送他们 。
如果你看了Elixir的IO.puts 函数实现 ：
~~~
    
    def puts(device \\ group_leader() , item) do
        erl_dev = map_dev(device)
        :io.put_chars erl_dev  , [ to_iodata(item) , ?\n ]
    end 
    
:erlang.group_leader返回的默认设备 是I/O server 的PID。
>
    C:\Users\Lenovo>iex --sname one
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(one@yiqing)1>

>
   C:\Users\Lenovo>iex --sname two
   Eshell V7.0  (abort with ^G)
   Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
   iex(two@yiqing)1> Node.connect(:"one@yiqing")
   true
   iex(two@yiqing)2> :global.register_name(:two , :erlang.group_leader)
   :yes
   iex(two@yiqing)3> 

接着在one窗口中：
>
    :ok
    iex(one@yiqing)2> two = :global.whereis_name :two
    #PID<9031.9.0>
    iex(one@yiqing)3> IO.puts(two ,"Hello")
    :ok
    iex(one@yiqing)4> IO.puts(two ,"World!")
    :ok
    iex(one@yiqing)5>
此时在two窗口中：
>
    iex(two@yiqing)4> Hello
    iex(two@yiqing)4> World!
    iex(two@yiqing)4>

## 节点是基础的分布式
    
    

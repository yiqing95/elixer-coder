并行编程 -  使用进程来做分治 
================

已经看过Elixir语法基础：modules functions types branching recursion 和模式匹配。这些东西已经可以应付大部分事情了，虽不是
太优雅 但已经差不多完了。
然而 ，有另一个世界浮现出来了  -- 并发编程

芯片制造 多核 桌面机 平板 手机

作为开发人员我们的问题就出现了 -- 当前的语言经常被设计为 单线程，单路径 单个执行上下文。
多数语言对使用多核并没有暴露好的设施，这就是ERTS和Erlang/Tlixir 真正让他们与众不同的地方。并发被内置在语言中了，也是语言
的首要约束，如果不能很好的处理并发，语言就是失败额。

## 并行计算和并发计算

这两个概念是不一样的。

我们可以使用 **context**上下文此词来讲线程或者而进程。明显地他们是不同的 但某种角度他们共享一些概念 相对于并行 VS 并发

并行计算 只是简单的两个或者多个同时地 上下文的执行 。
被执行的上下文是同时地，在执行间没有切换和中断 。

并发处理有些不同，他可以表现为并行 但实际上对并行不保证 。 比如 两个将要执行的上下文，但竞争同一个CPU 。调度器在二者间执行
，基于一些标准(缓存失效 死线优先级 ， 分支失效 ，或者其他)
在并发执行中，处理可能是并行的，但CPU 可能实际上被快速地在任务间切换。

单核机器运行多个进程就是并发执行的极好的例子。每个进程看似同时计算的，但是 ， 实际上 是被中断的，挂起的 和重新恢复多次。
甚至千万次每秒钟 。

假设给此机器添加更多的核 ，机器就可以并行地执行更多进程 ，但人就并发地做千万次这样的事情 。

## Erlang 进程和 OS 进程

当在Erlang上下文中讲进程时 ， 我们经常指的是Erlang 进程 而不是 OS进程 。
他们有很微妙但很重要的区别。
OS 进程被操作系统 调度 控制 ，或者更正确的 是内核 。内核的任务 关于 入队， 出队 ， 编组数据 ，内存分配 ，其他任务需要
平滑的进程执行。Erlang进程 ，是对于Erangl VM（BEAM）的本地进程 。ERTS被视为内核在此情况下 。它管理负责这些进程的调度和管理
。

另一个重要区别是重量问题 ，典型地，当考虑OS进程时，他们是重量级的 要处理的大块头的对象 ，不考虑进程交互的话。
Erlang 进程相反，是非常轻量级的，对单个的Erlang 虚拟机有成千上万进程同时运行很正常（进程 数量 可以相当 OO语言中的对象数量）

## 并行map
~~~

    defmodule MyMap do
      @moduledoc false
    
      def pmap(collection , f) do
        collection |>
        Enum.map(&(Task.async(fn -> f.(&1) end )) ) |>
        Enum.map(&Task.await/1)
      end
    end
~~~

在交互型会话中执行：
>
    iex(1)> import_file "my_map.ex"
    {:module, MyMap,
     <<70, 79, 82, 49, 0, 0, 6, 68, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 169, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:pmap, 2}}
    iex(2)> MyMap.pmap(1..10000, &(&1 * & 1))
    [1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256, 289, 324,
     361, 400, 441, 484, 529, 576, 625, 676, 729, 784, 841, 900, 961, 1024, 1089,
     1156, 1225, 1296, 1369, 1444, 1521, 1600, 1681, 1764, 1849, 1936, 2025, 2116,
     2209, 2304, 2401, 2500, ...]

执行很快 实际上加载了10000进程（1万个进程！）使用了机器上的所有核 。    

## Elixir进程基础

Elixir进程是自包含的抽象。进程的每个上下文独立于其他进程的上下文。进程间通过消息共享信息。

这被认为是 **actor-model** ，每个进程是一个actor，能够发送和接受消息从其他actors 。基于消息内容，一个actor可以执行特定
动作（actions）。这就是Elixir进程基础： 自包含的actors操作在发送给他们的信息上 结果经常发送回调用者进程 。

并发进程可不似上面的全部内容 没那么简单。

有一些函数自动对大部分的Elixir模块和iex会话内部可用 。

## self 
前面已经见过进程标识符了 ， 现在来解释相关的那个数字
>
    iex(4)> self
    #PID<0.57.0>

self/0 函数的返回值是一个进程标识符，当前进程（the REPL 在此情况下）的标识符 。标识符中的数字是进程地址 。

- 第一个数字 0在此情况下 告诉我们进程所在的Erlang节点
- 第二个数字，57在此情况下 是进程号的前15位，进程索引的一部分。
- 最后  最后一个数字， 0在此情况下 进程索引的剩余部分，典型地 16-18位 。

此三数字给了我们任何进程的全地址。我们可以使用此引用符作为地址来发送消息。

### 发送消息
直观上的 ，我们可以使用 send/2 函数在进程间发送消息 。
现在 我们可以给我们自己发送消息：
>   
    iex(5)> me = self
    #PID<0.57.0>
    iex(6)> send me , :ping
    :ping

我们创建了一个引用到我们自己，叫 me ， 之后发送一个 :ping 原子给我们自己使用 send/2 .

发送消息看起来很简单。接收消息也比较简单 。
## Receiving 消息：

为了接收发送给我们自己的消息，我们需要使用receive块 。或许 并不惊奇，receive块可能感觉很像特殊形式的case ，哪儿变量匹配通
过发送自其它进程（或者我们自己），让我们接收我们自己的ping：
>
    iex(7)> receive do
    ...(7)> x -> IO.puts("#{inspect x}")
    ...(7)> end
    :ping
    :ok
    
我们接收了原子 ;ping 打印原子的表达式 返回了:ok .
这就是模式匹配展示给我们的美 。
然而，如果任何其他进程在我们发送:ping 之前也发送了消息给我们 ，那么我们会先接收到那个消息 ，消息会被简单的入队列 。

发送消息给一个进程并不会影响发送者进程。消息会被放在进程的消息队列中。消息会一直在哪呆着知道进程决定检查他的队列。
如果接受者进程从不检查队列，许多消息会被发送，这个进程会 可能崩溃掉 因为消息是占空间的，在进程生存期间这个空间永不会被回
收的，消息队列大小相当大允许入队的消息数也依赖于每个消息的大小。

因为我们可以在接受消息之前可以入队一些消息，我们可以创建一个跟自己对话的进程。
>
    iex(10)> 1..5 |> Enum.map(&(send(me, &1 * &1 )))
    [1, 4, 9, 16, 25]
    iex(11)> receive do
    ...(11)> x -> x
    ...(11)> end
    1

这里给自己发送了五个平方 我们接受第一个。
我们可以继续接收接下来的四个平方；但一个个接受确实一些冗繁 ，flush/0 帮助函数很有用 在测试交互会话的消息传递是很有用
可以dump 当前进程收件箱的 接下来的消息：
>
    iex(12)> flush
    4
    9
    16
    25
    :ok
    
进程给自己发送和接受消息不是那么令人激动的，接下来看看创建我们自己的进程。
    
## Spawn

Elixir 核心模块给我们提供了 spawn/1 和 spawn/3 函数用于创建进程。这些可用于创建单独的进程 用来计算一些结果并把结果发回去
或者正在地，你可以执行任何你能想到的工作。

spawn/1 函数接受一个 无参的函数 并执行该函数在一个新的进程中。
>
    iex(13)> spawn fn ->6 *7 end
    #PID<0.20080.0>

注意新的进程标识符被返回了，而不是计算结果。 
使用Process.alive?/1 函数 我们可以看到进程的死活：
>
    iex(14)> pid = spawn fn -> 6 * 7 end
    #PID<0.20082.0>
    iex(15)> Process.alive?(pid)
    false

进程随函数的返回立即退出了！分化的进程没有什么事情要做了；结果被丢弃 进程 和其上下文 被标识为用于清除和丢弃。
如果进程因为某些不正常原因 一个激发的错误 退出 ， 比如 他不影响或者通知父进程：
>
    iex(16)> spawn fn ->raise :oops end
    #PID<0.20085.0>
    iex(17)>
    22:06:32.168 [error] Process #PID<0.20085.0> raised an exception
    ** (UndefinedFunctionError) undefined function: :oops.exception/1 (module :oops is not available)
        :oops.exception([])
        (stdlib) erl_eval.erl:669: :erl_eval.do_apply/6
        (stdlib) erl_eval.erl:877: :erl_eval.expr_list/6
        (stdlib) erl_eval.erl:404: :erl_eval.expr/5

消息被日志记录了 生活还是继续了（上例中跟书中输出结果很不一样！把 :oops 换为"oops" 就好
>
    iex(19)> spawn fn -> raise "oops" end
    #PID<0.20094.0>
    
    22:16:38.249 [error] Process #PID<0.20094.0> raised an exception
    ** (RuntimeError) oops
        :erlang.apply/2
）    

我们想让分离的进程的结果，我们需要告诉进程发送回他当其完成计算时。
>
    iex(20)> parent = self()
    #PID<0.57.0>
    iex(21)> spawn fn ->send(parent, 6 * 7) end
    #PID<0.20097.0>
    iex(22)> receive do
    ...(22)> x -> IO.puts("#{inspect x}")
    ...(22)> end
    42
    :ok

我们创建了一个父进程（当前）的引用，并分裂了而一个新的进程 发送结果6*7到父进程最后在父进程中我们收到了结果并打印其到标准
输出。

同样，这种类型在进程间发送消息的步骤是比较冗长乏味且用途不广 。 因此我们使用 spawn/3 函数。

【spawn/1 和 spawn/3 都通过编译器 内联 更进一步 Erlang只有spawn/3 函数， 并且参数给Elixir的spawn/3 同Erlang一样，这样做
可以保证两个语言的一致性】

spawn/3 函数需要我们以老的Erlang语法指定函数 ，但允许我们更好地创建进程（其做更有用的计算）。

老的Erlang语法是指定 模块， 函数 和参数 ， 即使none，以元祖的形式。
就是说 如果我们想加载Worker模块的 do_work/0 函数 我们需要传递下面的给spawn/3 :
>   spawn(Worker, :do_work, [])

幸运的是 这个在spawning 函数中是一致的。
文件： worker.exs
~~~
    
    defmodule Worker do
        def do_work do
            receive do
                {:compute, x , pid } ->
                    send pid, {:result, x * x}
            end
        end
    
        do_work()
        
    end
~~~
我们的函数不是那么有趣，但当前我们只对基础结构有更多的兴趣。

一旦启动， 我们的函数等待一个消息 以元祖的形式, {:compute, x , pid } 其中 :compute 标记消息， x 是我们希望计算平方的数字。
pid是发送者进程ID 用来发送返回结果 （回调地址的用途）。
一旦这个进程接受了一个元祖 ，他发送结果给调用者进程 并将其加载到一个无限循环中。

【Tagging messages 是一种通用的实践 以便于我们可以很容易的区分消息（socketIO|WebSocket 也类似这样呢），如何解析，执行什么
动作等等
无限循环比你想的更通用，许多语言和框架以这种形式表现。Elixir，只是使之对程序员更显式而已。
】

在一个交互会话中，我们可以导入模块 并分离它到另一个线程中：
>
    iex(1)> import_file "worker.exs"
    {:module, Worker,
     <<70, 79, 82, 49, 0, 0, 5, 52, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 130, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:do_work, 0}}
    iex(2)> pid = spawn(Worker, :do_work, [])
    #PID<0.64.0>
    iex(3)> Process.alive?(pid)
    true

我们的工作者进程在等待另一个进程来提供消息让其工作：
>
    iex(4)> send pid , {:compute, 4 , self() }
    {:compute, 4, #PID<0.57.0>}

我们现在应该有结果在收件箱里面了：
>
    iex(5)> flush()
    {:result, 16}
    :ok

进一步，看看我们的进程是否还活着 会得到 实际上 仍旧运行着并且可以接受更多的工作：
【实际跟描述不符？ 版本问题：
~~~

    iex(6)> Process.alive?(pid)
    false
    iex(7)> send(pid, {:compute, 16, self})
    {:compute, 16, #PID<0.57.0>}
    iex(8)> flush
    :ok
~~~
】
    
Worker 模块不是非常有弹性，下面的例子就会使之down掉:
>
    iex(15)> send(pid, {:compute, "square this", self()})
    {:compute, "square this", #PID<0.57.0>}
    iex(16)>
    00:12:10.878 [error] Process #PID<0.78.0> raised an exception
    ** (ArithmeticError) bad argument in arithmetic expression
        iex:5: Worker.do_work/0
    iex(16)> Process.alive?(pid)
    false        

这种情况下， 我们可能实际上想通知进程退出了以便于不在给他发消息，或者在发送更多消息前复活他。
我们可能要花一些时间思考spawn/3函数的工作机制或者 只需要看看spawn_link/3 函数，专门解决这个问题的.

### Process links 
进程连接 在进程间创建关系 并允许在二者间使用另一个通讯管道 。管道允许进程当另一个进程死亡时接收信号。
级联进程的死亡的功用看起来不那么明显，但 确证明是相当有用的 特别是在 **快速失败**的哲学上。

对复杂系统，有很多进程一起工作来 建模 和 组成系统 ，这些中的许多进程将会互相关联 或可能相互依赖彼此的结果。当一个进程死亡
，因为不在有if问题存在，程序员将不得不做出决定：程序员应该确信当一个进程死亡时的所有可能性和状态，或者杀死所有的依赖进程
并以干净的状态来重启失败的进程？

当假设是有限时 系统的全局设计变得相对容易了，失败时应该采取的步骤是明确的。即 系统变得更简单 因为 当假设是有限和清晰时，
失败明确的。

进程连接就用于这种目的，允许依赖的进程的级联失败 或者下游进程在上游进程失败时级联死亡 
，在这之后做什么是进程监控的主题。

### Spawning with links

我们可以派生一个进程 使用已建立的连接（父子进程间），使用 spawn_link/1 和 spawn_link/3 完成。

用spawn_link/1 来替换 spawn/1 和你期望的工作一样；某些情况下二者看起来一样：
>
    iex(1)> spawn_link fn -> 6*7 end
    #PID<0.59.0>
    iex(2)>

然而 区别是立即创建了一个link 如果子进程在其启动阶段失败父进程被通知 ，比如 如果派生了一个立即失败的子进程 ，错误或被正确
地扩散到父进程：
>
    iex(2)> spawn_link fn ->raise "failing" end
    ** (EXIT from #PID<0.57.0>) an exception was raised:
        ** (RuntimeError) failing
            :erlang.apply/2
    
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    
    07:24:41.231 [error] Process #PID<0.61.0> raised an exception
    ** (RuntimeError) failing
        :erlang.apply/2
        
连接的进程不是总杀死父进程，而 错误的传递和自己吃终结的**原因**有关。
比如我们可以创建一个更健壮的工作者进程版本 可以接收退出信号：
>
    defmodule Worker do
        def do_work() do
            receive do
                {:compute, x, pid} ->
                    send pid, {:result, x * x}
                {:exit, reason} ->
                    exit(reason)
            end
            do_work() # recursive instead of  while loop !
        end
    end

~~~
给在运行的子进程发送 exit 信号后 子进程不在运行了 父进程是不受影响的。
然而 我们可以发送一个强壮的 exit信号 因为我们在请求退出原因，，因而 这样的原因可以冒泡到父进程去。
在Elixir中有两个标准的退出原因： :normal 和 :kill .
其他任何原子也可以被使用，也有很多进程规则可用用来处理 ，可以看看Process.exit/2 获取更多资讯。

~~~
  
    iex(17)> import_file "worker2.exs"
    iex:1: warning: redefining module Worker
    {:module, Worker,
     <<70, 79, 82, 49, 0, 0, 5, 156, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 130, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:do_work, 0}}
    iex(18)> pid = spawn_link Worker, :do_work, []
    #PID<0.87.0>
    iex(19)> send pid, {:compute, 4 , self }
    {:compute, 4, #PID<0.57.0>}
    iex(20)> flush
    {:result, 16}
    :ok
    iex(21)> Process.alive? pid
    true
    iex(22)> send pid, {:exit, :normal}
    {:exit, :normal}
    iex(23)> Process.alive? pid
    false
~~~

### Process monitor  进程监控

进程监控和进程链接些许不同，但很像。

监控是特殊的 可跟踪的 单向链接 。

链接是双向的 便于很多进程的级联死亡 
两个进程中的一个失败导另一个不可用是使用进程链接的很好例子。
然而，或许一个进程只需要简单地只需要知道另一个进程的状态 。
因为 监控器是可追踪的 移除掉监控器不会移除所有的其他监控器。断掉链接 在两个或者更多的进程间也做的这件事，它会移除掉每个链接
级联地 破坏掉链接提供的假设。

进程监控派生于进程链接的思想。 他们允许监控进程来接受关于被监控进程状态的消息 。
为了完成这个，我们使用 spawn_monitor/1 和 spawn_monitor/3 , 其功用和你期待的一样 类似于spawn 和 spawn_link .
然而 ， 不是简单返回子进程的PID，他们返回子进程PID的元祖和对监听器的引用。监听器引用可以用于移除监听器：
>
    iex(1)> {pid, _ } = spawn_monitor(fn -> :timer.sleep(500) end )
    {#PID<0.65.0>, #Reference<0.0.2.30>}
    iex(2)> Process.alive? pid
    false
    iex(3)> flush
    {:DOWN, #Reference<0.0.2.30>, :process, #PID<0.65.0>, :normal}
    :ok
    
使用进程监听器很像使用链接，然而，不是一个进程失败或者常规终止导致进程的级联终止，监控进程接收一个常规消息在其收件箱中（
关于被监控的进程的死亡），监听进程可以接收消息并被给予执行某些行为的机会（根据接收到的这些消息）。

### 在进程中存储状态

Elixir进程很伟大，迄今所见 你不需要进程记住任何东西。 但我们总有这样的需求（状态记忆 数据存储）

通过spawn/3 可以容易解决 ，第三个参数可以看做进程的初始状态。进制之后可以开始其运行使用这个初始状态。之后问题变成：
进程如何修改其状态？Elixir的数据是不可变的，所以进程如何修改这个数据？
答案就在 **tail-recursive infinite loop** 在每次loop循环中进程的状态都被传递，伴随着所有的修改给他自己。
 
让我们创建一个简单的 key-value 存储进程来示例此方法，
>
    defmodule KB  do
        def start_link do
            spawn_link(fn -> loop(%{}) end)
        end
    
        defp loop(map) do
            receive do
                {:put, key , value , sender} ->
                    new_map = Map.put(map,key,value)
                    send sender, :ok
                    loop(new_map)
                {:get, key , sender} ->
                    send sender, Map.get(map, key)
                    loop map
            end
        end
    end
    
start_link 函数是一个方便的 用来分裂一个KV进程的函数，简单的开始循环以一个空map。do loop也是相当简单的。
匹配两种不同类型的消息:put 和 :get 如果被给予了一个 :put 消息 ，我们用一个新key 使用函数Map.put/3更新map（我们的内部状态）
之后发送给调用者进程 :ok 消息。 最后递归地使用更新后的map。 如果我们被给的是一个:get  ,我们发送一个值，或者更准确地，
Map.get/2 的结果 会给进程 ...? 。        

保存模块定义到一个文件中并在交互式会话中测试：
>
    iex(25)> import_file("kv.exs")
    {:module, KV,
     <<70, 79, 82, 49, 0, 0, 7, 8, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 133, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:loop, 1}}
    iex(26)> pid = KV.start_link
    #PID<0.106.0>
    iex(27)> send pid, {:get, :a , self}
    {:get, :a, #PID<0.57.0>}
    iex(28)> flush
    nil
    :ok
    iex(29)> send pid, {:put, :a, 42, self}
    {:put, :a, 42, #PID<0.57.0>}
    iex(30)> send pid, {:get, :a, self}
    {:get, :a, #PID<0.57.0>}
    iex(31)> flush
    :ok
    42
    :ok

【记着最后的:ok 是flush/0的返回值，不是消息队列中的消息的一部分】
在插入一个key到KV存储中后，我们就可以取回他了

这是一个基本的模式用来在进程中处理状态。

## 命名进程
当你使用过进程id后 拥有进程id的需求变得有点冗繁，然而 有个更简单的机制用来引用一个进程 -- 进程注册。
除了（instead of）通过PID引用对象来引用进程，我们可以注册一个原子用于进程ID。

比如，用我们前面的Key-Value 存储，我们可以为进程注册PID之后引用他 通过原子发送消息
这通过Process.register/2 函数来完成：
>
    iex(32)> import_file "kv.exs"
    iex:1: warning: redefining module KV
    {:module, KV,
     <<70, 79, 82, 49, 0, 0, 7, 8, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 133, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
     {:loop, 1}}
    iex(33)> pid = KV.start_link
    #PID<0.118.0>
    iex(34)> Process.register(pid, :kv)
    true
    iex(35)> send :kv, {:put, :a, 42, self}
    {:put, :a, 42, #PID<0.57.0>}
    iex(36)> flush
    :ok
    :ok
    iex(37)> send :kv, {:get, :a, self}
    {:get, :a, #PID<0.57.0>}
    iex(38)> flush
    42
    :ok

这里的代码和前面一样；我们只是用:kv 进程名称来引用运行的KV存储而不是原始的进程ID 。

## 进程模块
我们已经用了进程模块的几个函数：Process.alive?/1 和 Process.register/2 .但还有更多的有用的函数在进程模块中。推荐大致浏览
下该模块中的函数。

## 应用例子
~~~

    defmodule PingPong do
      @moduledoc false
    
        def start_link do
          spawn_link(fn -> loop() end)
        end
    
        defp loop do
          receive do
            {:ping, sender} ->
              send sender, {:pong, self}
          end
          loop # 递归调用自己 等待下次:ping 消息。
        end
    end
    
    """
      iex(39)> import_file "ping_pong.ex"
      {:module, PingPong,
       <<70, 79, 82, 49, 0, 0, 5, 244, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 135, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
       {:loop, 0}}
      iex(40)> pid = PingPone.start_link
      ** (UndefinedFunctionError) undefined function: PingPone.start_link/0 (module PingPone is not available)
          PingPone.start_link()
      iex(40)> pid = PingPong.start_link
      #PID<0.132.0>
      iex(41)> send pid, {:ping, self}
      {:ping, #PID<0.57.0>}
      iex(42)> flush
      {:pong, #PID<0.132.0>}
      :ok
    """
~~~

让这个例子更有趣 为其添加状态 让其更像一个心跳进程。
【心跳，分布式计算中的术语，ping或者监控一个进程或者机器的概念。如果机器在一个可接受的间隔内没有响应，进程或者机器认为
死掉了】
我们会分步骤地开发一个HeartMonitor模块 。始于定义HeartMonitor进程应该监听的消息，比如 我们应该定义接收 和处理 :pong消息。
另一个应该处理的消息用来 添加，何其关联的 用于移除监听器的消息。 我们也应该考虑用于pearing into当前监听器的消息，所以
让我们添加一个消息用于 :list_mointors .和监听当前监控器有关，心跳监控器的用户 可能对那些进程还存活（什么进程死了）很好奇。
 所以我们可添加用于这些小的模式 。这些应该对一个简单的心跳监听器足够了。
 
 ~~~
 
    defmodule HeartMointor do
      @moduledoc false
    
        def start_link do
          spawn_link(fn -> loop() end)
        end
    
        defp loop(state) do
          receive do
            {:pong, sender} ->
              loop(handle_pong(sender, state))
            {:mointor, pid} ->
              loop(%{state | mointors => [pid] ++ state.monitors } )
            {:demonitor, pid} ->
              loop(%{state |  :monitors => state.monitors -- [pid]})
            {:list_mointors, sender} ->
              send sender, {:reply, state.monitors}
              loop(state)
            {:list_alive, sender} ->
              send sender, {:reply, state.alive}
              loop(state)
            {:list_dead, sender} ->
              send sender, {:reply, state.dead}
              loop(state)
          end
        end
    end~
 ~~~
对于:pong消息，我们循环调用另一个内部函数，handle_pone 

当我们收到一个:monitor消息，我们添加了传递的pid给我们的内部监听器列表，相似地，接受一个:demonitor 消息，我们从我们的监听
器列表中移除掉跟定的pid。
最后，所有的:list_ 消息响应给调用者进程用请求的列表在{:reply, list} 元祖中。

移至handle_pong/2 函数，此函数需要完成什么？毫无疑问的一个答案就是需要返回更新后的状态map 因为内部循环期望它。但显然，
需要做更多。心跳进程会发送pings 给每个被监控的进程。在此步，我们创建outstanding pings的列表 ，这样 handle_pone/2 函数需要
处理outstanding ping 。
~~~

     defp handle_pong(sender, state) do
          dead = state.dead -- [sender]
          pending = Map.delete(state.pending, sender)
          alive = state.alive
          unless sender in state.alive do
            alive = [sender] ++ alive
          end
          %{state | :alive => alive, :dead => dead, :pending => pending }
        end
~~~

基本完成了一个能工作，简单的，心跳监控进程 。接下来只涉及几步了

~~~

    pending = state.monitors |>
    Enum.map(fn(p) ->
    send p, {:ping, self}
    Map.update(state.pending, p, 1, fn(count) -> count + 1 end)
    end) |>
    Enum.reduce(%{}, fn(x, acc) ->
    Map.merge(x, acc, fn(_, v1, v2) -> v1 + v2 end)
    end)
~~~
我们映射当前的监听器列表，给每个进程发送一个ping ，并更新或者插入进程key到outstanding后者pending map中。因为这是一个流
我们时间上创建了新的pending列表对每个monitor。 这样我们必须reduce和合并更新的版本。


超时
>
    iex(43)> receive do
    ...(43)> _ -> 42
    ...(43)> after 5000 ->
    ...(43)> -42
    ...(43)> end
    -42
    
## Work pool

工作池的概念跟线程池类似。有一些静态分配的工作线程（可以执行通用目的的工作），给一些任务，线程或者工作者 就会启动，
计算工作，返回结果。当池全部被消费时 队列的部分仍旧需要调度工作。

典型的工作池有一些类型的调度进程。简化起见，可以使用FIFO-scheduler .简单地在工作到来时执行就行了 没有特殊的排序(重排序)。
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\6>mix new workpool
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/workpool.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/workpool_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd workpool
        mix test
    
    Run "mix help" for more commands.

之后开始创建scheduler进程在./lib/workpool/ 目录
【在创建一个子模块时创建一个和根模块同名的文件夹是一个标准实践 ， 比如Workpool. Scheduler 的根或者基目录 】
~~~

    defmodule Scheduler do
      @moduledoc false
      
    end
~~~
创建典型的内部循环用来执行消息处理。
我们会响应一些消息，比如工作入队 和 :DOWN 消息来通知请求者失败的请求。
对于内部循环，用receive do 循环等待并对消息响应

~~~
    F:\Elixir-workspace\elixer-coder\learning-elixir\6\workpool>iex -S mix
    Eshell V7.0  (abort with ^G)
    Compiled lib/workpool.ex
    Compiled lib/workpool/scheduler.ex
    Generated workpool app
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> scheduler = Workpool.Scheduler.start_link
    #PID<0.101.0>
    iex(2)> send scheduler , {:queue, fn(x) -> 2 * x * x end, 4, self }
    {:queue, #Function<6.54118792/1 in :erl_eval.expr/5>, 4, #PID<0.99.0>}
    iex(3)> flush
    32
    :ok
~~~

因为我们使用了monitor而不是links scheduler不会失败的如果一个异常在worker中触发：
>
    iex(4)> send scheduler, {:queue, fn(_) -> raise "oops" end , [] , self}
    {:queue, #Function<6.54118792/1 in :erl_eval.expr/5>, [], #PID<0.99.0>}
    iex(5)>
    15:51:44.382 [error] Process #PID<0.106.0> raised an exception
    ** (RuntimeError) oops
        (workpool) lib/workpool/scheduler.ex:12: anonymous fn/3 in Workpool.Scheduler.loop/1
    iex(5)> Process.alive? scheduler
    true

如我们所料，worker进程失败了但scheduler进程依旧存活。

这个工作池调度器不是那么好用。消费者进程必须知道一些关于scheduler的事情，比如 进程ID 。我们可以使用进程注册来改善，但
消费者进程如何知道只是看是一个独立的调度器还是在已有进程上注册？

一种可行的方法是让Workpool模块做启动和进程注册。这样，在一个地方 所有的消费者进程都能简单使用注册的原子而不是需要知道
其PID引用。

为了完成这个，我们需要添加一个函数到Workpool模块，比如说函数叫start ：
start/0:
>    
    def start do
        pid = Workpool.Scheduler.start_link
        true = Process.register(pid, :scheduler)
        :ok
    end
    
这样，我们可以从Workpool模块加载scheduler，工作池的消费者不必知道Workpool.Scheduler 模块。 
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\6\workpool>iex -S mix
    Eshell V7.0  (abort with ^G)
    Compiled lib/workpool.ex
    Compiled lib/workpool/scheduler.ex
    Generated workpool app
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> Workpool.start
    :ok
    iex(2)> send :scheduler, {:queue, fn(x) -> x * x end, 7, self}
    {:queue, #Function<6.54118792/1 in :erl_eval.expr/5>, 7, #PID<0.99.0>}
    iex(3)> flush
    49
    :ok
    
为了使工作池工作的更好需要添加一些东西，进程间发送消息经常做不正确。传递的元祖中有很多变数，对发送进程也没有一个好办法知道
它犯了错误。

我们可以给Workpool模块添加一些函数 对调度器是公共的API，之后 工作池的消费者进程不必知道消息格式 更容易感知api的变化。
因为我们只有一个公共消息，我们只需要添加一个queue/2 函数
>   
    def queue(fun , args ) do
        send :scheduler, {:queue, fun, args , self}
        :ok
    end
    
这样我们可以同Workpool模块 简单地通过 start/0 和 queue/2 进行交互。
    
>
    F:\Elixir-workspace\elixer-coder\learning-elixir\6\workpool>iex -S mix
    Eshell V7.0  (abort with ^G)
    Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> Workpool.start
    :ok
    iex(2)> Workpool.queue(fn(x) -> x * x * 2 end, 4)
    :ok
    iex(3)> flush
    32
    :ok
    
这样对其他终端消费者更易用。只需要他们简单地熟悉Workpool模块的API，    
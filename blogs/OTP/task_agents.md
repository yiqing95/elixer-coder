Tasks
-----
Elixir task 是一个运行在后台的函数。

~~~

    defmodule Fib do
      @moduledoc false
    
      def of(0), do: 0
      def of(1), do: 1
      def of(n), do: Fib.of(n-1) + Fib.of(n-2)
    
    end
    
    IO.puts "Start the task"
    worker = Task.async(fn -> Fib.of(20) end)
    IO.puts "Do something else"
    # ...
    IO.puts "Wait for the task"
    result = Task.await(worker)
    IO.puts "The result is #{result} "
~~~

对Task.async 的调用创建了一个独立的进程 此进程运行指定函数。async返回值是一个任务描述符(实际是一个PID和一个ref引用)，后期
会使用它来标识任务的。

一旦任务运行，代码会继续进行其他的工作。当想获取函数的值是调用：Task.await,传递进任务描述符。此调用等待我们的后台任务完成，
并返回其值。

当我们运行它 我们看到：
>
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/tasks-agents/tasks (master)
    $ elixir tasks1.ex
    Start the task
    Do something else
    Wait for the task
    The result is 6765

我们也可以传递Task.async 模块的名称和函数名称，随带任何参数：
> 
    worker = Task.async(Fib, :of, [20] ) # 很像php中的call_user_func_.. 函数的签名哦！就像Callable 的格式呢。
    
## Tasks and Supervision
Tasks 作为OTP 服务实现，此即意味着我们可以添加他们到我们的应用程序的supervision树中。我们可以通过两种方式来做。

首先，我们可以连接link 一个task到一个档期supervised process 通过调用start_link替代async调用。这个比你想象的影响还要小。
如果运行在task中的函数奔溃掉了并且我们使用了start_link,我们的进程会立减终止的。如果换之我们使用的是async，我们的进程
只会在后续 在奔溃任务上调用await时终止。
    
第二种方式 是直接从supervisor运行他们。这种方式跟其他指定任何工作者一样：
~~~
    
    import Supervisor.Spec
    children = [
        worker(Task, [ fn -> do_something_extraordinary() end ])
    ]
    
    supervise children, strategy: :one_for_one


## Agents
agent 是后台可以维护状态的进程，状态在同一个进程或者节点中可用从不同的地方访问 或者跨越多个节点。
    
当我们启动一个agent时传递一个函数来设置此初始状态。
    
我们可以查看此状态通过Agent.get 传递它一个agent描述符和一个函数，agent运行那个函数在当前状态上并返回结果。
    
我们也可以使用Agent.update 来修改agent持有的状态。通get操作符，我们传递一个函数，不同于get的是函数的结果变为新的状态。
>
    iex(2)> { :ok, count } = Agent.start(fn -> 0 end)
    {:ok, #PID<0.65.0>}
    iex(3)> Agent.get(count, &(&1))
    0
    iex(4)> Agent.update(count, &(&1 + 1))
    :ok
    iex(5)> Agent.update(count, &(&1+1))
    :ok
    iex(6)> Agent.get(count , &(&1))
    2

除了进程PID外，我们也可以给agent一个local或者global名称，并使用这个名称访问他们，在此情况下，名称会冠以Elixir.前缀的，
>
   iex(7)> Agent.start(fn -> 1 end , name: Sum)
   {:ok, #PID<0.71.0>}
   iex(8)> Agent.get(Sum, &(&1))
   1
   iex(9)> Agent.update(Sum, &(&1 + 99))
   :ok
   iex(10)> Agent.get(Sum, &(&1))
   100

   
使之分布化
------------
因为agents和tasks 作为OTP servers来运行的，他们已经可以是可分布的了，所以要做的只是给我们的agent一个全局可访问的名称，只需要
做一行改变：
> @name {:global, __MODULE__ }

## Agents Tasks 还是GenServer？
什么时候使用agents和tasks ，又什么时候使用GenServer呢?

答案是使用能工作的最简单方法。Agents和tasks在你处理非常特定的后台活动时很棒。而GenServer（如其名所示）更加的通用。

你可以通过封装agents和tasks到一个模块中来消除选择（到底哪个好 该用哪个？）。这样我们可以很方便的从agent或者task实现切换
到一个成熟的GenServer 而不需要影响代码基。
   
    
    
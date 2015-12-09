进程开支
-------
Elixir中的进程开销是非常小的 。

~~~
    
    defmodule Chain do
      @moduledoc false
    
      def counter(next_pid) do
          receive do
              n ->
                send next_pid , n+1
          end
      end
    
      def create_processes(n) do
          last = Enum.reduce 1..n , self ,
            fn (_ ,send_to) ->
              spawn(Chain , :counter ,[send_to])
             end
    
          # start the count by sending
          send last , 0
    
          # and wait for the result to come back to us
          receive do
            final_answer when
            is_integer(final_answer) ->
              "Result is #{inspect(final_answer)}"
          end
      end
    
      def run(n) do
          IO.puts inspect :timer.tc(Chain , :create_processes , [n] )
      end
    
    end

~~~    
一亿个进程（顺序化的） 大概用7秒！这性能直接使我们呆掉了 。它改变了我们设计代码的方式 ，我们现在可以创建成千上万的帮助进程
每个进程可以有自己的状态，某种意义，进程在Elixir就像OO系统中的对象

### 连接两个进程
当两个进程连接后 一个进程退出后 另一个进程会收到信息的 。

spawn_link 在一个操作中 派生一个进程 并连接其到调用者
~~~
    
    defmodule Link2 do
      @moduledoc false
    
      import :timer , only:  [sleep: 1]
    
      def sad_function do
          sleep 500
          exit(:boom)
      end
    
      def run do
          spawn_link(Link2 , :sad_function , [])
    
          receive do
            msg ->
              IO.puts "MESSAGE RECEIVED #{inspect msg}"
    
            after 1000 ->
              IO.puts "Nothing happend as far as I am concerned "
          end
    
      end
    
    end
    
    #  运行
    Link2.run

~~~

>
    F:\Elixir-workspace\elixer-coder\spawn>elixir -r link2.ex
    ** (EXIT from #PID<0.46.0>) :boom

一旦我们的子进程死掉了 他会杀掉整个应用 ，这是连接进程的默认行为 ----- 当一个进程异常退出 ， 它会杀掉另一个的 。

如果你想自己处理另一个进程的死亡怎么办 ？ 劝你不要自己这么干 ， Elixir使用OTP框架来构造进程树，OTP有进程管理的概念（supervision）

即便如此 你仍可以 把连接进程的退出信号变为你可以处理的消息 藉此可以友好退出 

~~~
    
    defmodule Link3 do
      @moduledoc false
    
      import :timer , only: [ sleep: 1 ]
    
      def sad_function do
        sleep 500
        exit(:boom)
      end
    
      def run do
        Process.flag(:trap_exit , true)
        spawn_link(Link3 , :sad_function , [] )
    
        receive do
          msg ->
            IO.puts "MESSAGE RECEIVED #{inspect msg}"
    
           after 1000 ->
            IO.puts "Nothing happened as far as I am concerned "
        end
    
      end
    
    end
    
    Link3.run

~~~

>
    F:\Elixir-workspace\elixer-coder\spawn>elixir -r link3.ex
    MESSAGE RECEIVED {:EXIT, #PID<0.52.0>, :boom}
    
不管进程如何退出了， 或者简单的完成了处理，或者显式退出 ，或者触发了一个异常 都一样的收到了:EXIT 消息 ， 跟随了一个错误
然而跟了一个出错的详情 。

### 监控进程
连接 进程 双方都会收到彼此的通知的 。
跟连接进程不同的是  监控 让一个进程派生出其他进程 并在他们退出时得到通知，但没有反向通知----仅是单向的 。

当你监控一个进程时，你会收到一个:DOWN 消息当他退出或者失败时 ，【毛意思 --- 或者它并没有退出】 。

你可以使用spawn_monitor 来在我们派生一个进程时打开监控 。或者使用Process.monitor来监控一个已经存在的进程。然而当使用Process.monitor
时（或者链接到一个已经存在的进程时），会有潜在的竞争条件 --- 如果其他进程先于你的监控调用前死掉 ，你将不会收到通知。

spawn_link 和 spawn_monitor 版本是原子的，然而，你将总是可能捕获到一个错误 。


~~~
    
    defmodule Monitor1 do
      @moduledoc false
    
      import :timer , only: [ sleep: 1 ]
    
      def sad_method do
        sleep 500
        exit(:boom)
      end
    
      def run do
        res = spawn_monitor(Monitor1 , :sad_method , [])
        IO.puts inspect res
    
        receive do
          msg ->
            IO.puts "MESSAGE RECEIVED: #{ inspect msg}"
    
           after 1000 ->
              IO.puts "Nothing happened as far as  I am concerned "
        end
    
      end
      
    end
    
    Monitor1.run


~~~

>   
    F:\Elixir-workspace\elixer-coder\spawn>elixir -r monitor1.ex
    {#PID<0.52.0>, #Reference<0.0.4.1>}
    MESSAGE RECEIVED: {:DOWN, #Reference<0.0.4.1>, :process, #PID<0.52.0>, :boom}
    
效果跟连接一样！
    
那么什么使用使用link 什么时候使用monitor呢？
取决于你的进程语义 ，如果意图是一个进程失败后应该结束另一个 那么此时你需要的是links
但如果你需要知道什么时候其他进程会因某种原因退出 那么选择监控monitor
    
### 并行Map --  erlang中的 “hello world”
每本erlang相关的书都会有这个 parallel Map 函数定义 。
常规的map 将函数作用在一个集合的每个元素上后作为结果返回一个列表 ， 并行版做了同样的事情 ，但它是在独立进程中将函数
作用在每个元素上的 。
~~~
    
    defmodule Parallel do
    
        def pmap(collection , func) do
           me = self
           collection
           |> Enum.map(fn (elem) ->
                spawn_link fn -> (send me , {self , func.(elem)}) end
             end )
           |> Enum.map( fn (pid) ->
                receive do { ^pid , result } -> result end
             end )
    
        end
    
    end

~~~
>
    iex(1)> c("pmap.exs")
    [Parallel]
    iex(2)> Parallel.pmap 1..10 , &(&1 * &1)
    [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
    iex(3)>
    
 ### 斐波那契数列 服务器
 
 ~~~
    defmodule FibSolver do
    
        def fib(scheduler) do
            send scheduler , { :ready , self }
    
            receive do
                {:fib , n ,client } ->
                    send client , { :answer , n , fib_calc(n) , self }
                    fib(scheduler)
                { :shutdown } ->
                    exit(  :normal )
            end
        end
        # very inefficient , deliberately
        defp fib_calc(0) , do: 0
        defp fib_calc(1) , do: 1
        defp fib_calc(n) , do: fib_calc(n-1) + fib_calc(n-2)
    
    
    end
    
    defmodule Scheduler do
    
        def run(num_processes , module , func , to_calculate) do
            (1..num_processes)
            |> Enum.map(fn(_) -> spawn(module , func , [self]) end )
            |> schedule_processes(to_calculate ,[] )
        end
    
        defp schedule_processes(processes , queue , results ) do
            receive do
                {:ready , pid } when lenght(queue) > 0 ->
                    [next | tail ] = queue
                    send pid , {:fib , next ,self}
                    schedule_processes(procesess , tail , results )
    
                {:ready , pid} ->
                    send pid , {:shutdown}
    
                    if length(processes) > 1 do
                        schedule_processes(List.delete(processes , pid) , queue ,results)
                    else
                        Enum.sort(results , fn {n1, _} , {n2,_} -> n1 <=n2 end )
                    end
    
                    {:answer , number, results, _pid } ->
                        schedule_processes(processes , queue, [{number , result } | results])
    
                end
        end
    end
    
    to_processes = [37,37,37,37,37,37,37]
    Enum.each 1..10 , fn  num_processes ->
            {time ,result} = :timer.tc(Scheduler , :run , [ num_processes, FibSolver , :fib , to_process])
            if num_processes == 1 do
                IO.puts inspect result
                IO.puts "\n # time (s)"
            end
            :io.format "~2B ~.2f~n " , [num_processes , time/1000000.0]
    
    end         
 
 ~~~
 
 ## Agents
 
 Elixir 的模块只是函数的buckets（桶 | 容器） ，他们不能保存（hold）状态 ，但进程可以保存状态
 Elixir 自带了一个Agents模块 提供的模块接口使得我们封装进程状态很容易
 ~~~
    
    defmodule FibAgent do
    
        def start_link do
            cache = Enum.into( [{0,0} ,{1,1}] , HashDict.new)
            Agent.start_link(fn -> cache  end )
        end
    
        def fib(pid ,n) when n >= 0 do
            Agent.get_and_update(pid , &do_fib(&1 , n))
        end
    
        defp do_fib(cache , n) do
            if cached = cache[n] do
            {cached , cache}
    
            else
                {val , cache } = do_fib(cache , n-1)
                result = val + cache[n-2 ]
                {result , Dict.put(cache , n , result )}
            end
        end
    end
    
    {:ok ,agent} = FibAgent.start_link()
    IO.puts FibAgent.fib(agent, 2000)
 
 ~~~
 
 ## 进程式的思考问题
 如果你开始编程时是用的过程式 然后转移到面向对象风格 ，那么你那段时间 可能想问题都基于对象的（万物皆对象）
 
 同样的 当你的思考单元是进程时 ，每个正常的Elixir程序 会有很多 很多 很多进程 ，总的来说（by the large） 就像创建和管理对象那么容易。
 但切换这种思考方式需要花些时间 ，坚持就好了 。
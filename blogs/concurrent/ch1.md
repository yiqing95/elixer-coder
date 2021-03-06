actor-based model

Elixir 的一个核心特性 就是将代码打包进能够独立 且并行运行的小块的思想。

传统的程序普遍都不是多进程的 认为进程数太多会影响性能。

但Elixir没有这种顾虑，这归功于Erlang的虚拟机架构

Elixir 并发模型是 actor
----------
actor 是独立的进程，和其他进程不共享任何东西。 你可以派生新的进程，给他们发消息 并从他们返回消息。

过去我们可能需要使用线程或者操作系统该进程来完成并发。每次你就像打开了潘多拉的盒子那样（总有那么多可能的坑等着我们）。
但这些在Elixie中 都是多虑的，实际上Elixir开发者对创建进程很习以为常 。他们经常像类似java语言中创建对象式的创建进程 。

有一点要记住当我们在elixir中讨论进程时指的并不是原生的操作系统进程！
他们是erlang中支持的进程概念，可以跨多个cpu（跟原生os进程一样），但他们要轻量的多，我们很容易创建成千上万的进程在即便很
普通的电脑上 。

定义模块：
~~~
    
    defmodule SpawnBasic do
      @moduledoc false
    
      def greet do
        IO.puts "Hello "
      end
    
    end

~~~
看到 只是一个标准常规的模块
下面以不同方式运行它

~~~

    iex(1)> c "spawn_basic.ex"
    [SpawnBasic]
    iex(2)> SpawnBasic.greet
    Hello
    :ok
    iex(3)> spawn(SpawnBasic , :greet , [])
    Hello
    #PID<0.66.0>
    iex(4)>
~~~
spawn 函数可以分离出一个进程 ，其形式比较多，最简单的两种形式使得我们可以运行一个匿名函数或者一个模块中的命名函数并传递
一个参数列表。
该函数返回一个进程描述符，经常被称之为PID

我们创建了进程后 并不知道他什么时候被执行 ，只知道他有资格在符合条件时被运行。

## 进程间发送消息

在Elixir中使用send函数来发送消息 ，它接受一个pid 和待发送的消息 你可以发送任何东西，但貌似elixir开发者只发送原子或者元祖。
我们等待消息 使用 receive函数 ，此时它表现的像case 消息体作为参数


## 处理多个消息

~~~
    
    defmodule Spawn2 do
      @moduledoc false
    
      def greet do
        receive do
          {sender ,msg} ->
            send sender , {:ok , "Hello #{msg}"}
        end
      end
    
    end
    
    # here is the client
    pid = spawn(Spawn2 , :greet , [])
    
    send pid , {self, "World!"}
    
    receive do
      {:ok, message} ->
       IO.puts message
    end
    
    send pid , {self , "Yiqing "}
    receive do
      {:ok, message } ->
        IO.puts message
    end

~~~
运行：
~~~

       iex(1)> c "spawn2.ex"
       Hello World!
      
~~~
看到 我们的iex 程序“挂”住了 源于greet方法只接受一次发送 然后退出了 结果主进程再往其发送消息 就夯住了。

让我们改造下我们的client ：

~~~
    
    send pid , {self , "Yiqing "}
    receive do
      {:ok, message } ->
        IO.puts message
    
      after 500 ->
          IO.puts "The greeter has gone !"
    end

~~~
我们告诉receive方法 我们想超时 如果500毫秒还没响应的话 ，这里用到了称之为after的伪模式  。

但如何使我们的greet 多次接受消息，我们的第一反应就是弄个循环 在每次迭代上使用receive函数 但Elixie 没有loop！
然而我们有递归。
~~~
    
    defmodule Spawn4 do
      @moduledoc false
    
      def greet do
    
          receive do
              {sender , msg} ->
                send sender , {:ok , "Helllo , #{msg}"}
              # 递归啦！
              greet
    
          end
      end
    end
    
    # here is the client
    
    pid = spawn(Spawn4 , :greet , [])
    
    send pid , {self, "World!"}
    
    receive do
          {:ok , msg} ->
            IO.puts msg
    end
    
    send pid , {self , "Yiqing"}
    receive do
      {:ok ,msg} ->
        IO.puts msg
       after 500 ->
        IO.puts "The greeter has gone! "
    end
~~~

## 递归 循环 栈
上例中的greet 是递归调用的 或者会使您感到担忧 ， 每次它收到一条消息， 就以调用自己作为结束 。 在很多其他语言中这会为栈添加
一个新的帧 。在很大数量的消息接受后 你就会堆栈溢出了 。

在Elixir中不会发生这种事的 。因为有做 tail-call 优化 ，如果最后的调用是自己 那么就不会触发这次调用的 。替代的行为是
runtime（运行时）简单地跳回到函数的首部。如果递归调用拥有参数 那么当递归循环时 原始参数会被替换的 
请注意 递归调用必须是最后执行的 ，比如下面的就不是啦2
~~~
    
    def factorail(0) , do: 1
    def factorail(n) , do: n * factorail(n-1)
    
~~~
尽管递归调用物理的出现在尾部 ，但并不是最后执行的 函数必须乘上返回的n

为了做到尾部递归，我们需要把乘法移到递归里面去 这意味着需要添加一个聚合器accumulater
~~~
    
    defmodule TailRecursive do
    
    
        def factorial(n) , do: _fact(n ,1)
    
        defp _fact(0 , acc) , do: acc
        defp _fact(n , acc ) , do: _fact(n-1 , acc * n)
    
    end
~~~

OTP Supervisors
----------

Elixir风格的代码不需要担心崩溃 ，保证整体的应用持续运行。

设想一个典型的应用，如果一个未处理错误导致了一个异常的触发，应用停止了。知道他重启，不会再做其他事情了如果一个服务处理
很多请求，所有的请求可能丢失了。

此处的问题是 一个错误导致整个应用down掉。

但想像下，如果应用有成千上百的进程组成。每个只处理请求的一小部分。他们中的一个奔溃掉 其他的仍旧正常继续工作。你可能丢失它
正在做的工作，但你可以设计你的应用最小化那部分风险。并且等那个进程重启后，you ‘er back running at 100% 

在Elixir和OTP世界中，supervisors 执行所有的这些进程监控和重启工作。

Supervisors and Workers
=============

一个Elixir supervisor 只有一个目的-- 他管理一个或者多个工作者进程，（他也可以管理其他supervisors）

最简单情形，一个supervisor 是一个进程 他使用了OTP supervisor的行为， 给他了一个进程列表来监控并告诉他如果一个进程死了要去
做什么 ， 以及如何阻止重启循环（当进程重启后，死了，又被重启，又死了，不停这样...）。

为了做这个 ，supervisor 使用了erlang vm的进程连接和 进程监控设备。

我们可以以一个独立的模块写出一个supervisors，但elixir风格是在一行代码中包含他们。最简单的开始项目的方法是使用--sup flag
：
>
    yiqing@yiqing MINGW64 /f/Elixir-workspace/elixer-coder/projects/supervisor (master)
    $ mix new --sup sequence
    * creating README.md
    * creating .gitignore
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/sequence.ex
    * creating test
    * creating test/test_helper.exs
    * creating test/sequence_test.exs
    
    Your Mix project was created successfully.
    You can use "mix" to compile it, test it, and more:
    
        cd sequence
        mix test
    
    Run "mix help" for more commands.

打开sequence/lib/sequence.ex 文件
~~~
    
    defmodule Sequence do
      use Application
    
      # See http://elixir-lang.org/docs/stable/elixir/Application.html
      # for more information on OTP Applications
      def start(_type, _args) do
        import Supervisor.Spec, warn: false
    
        children = [
          # Define workers and child supervisors to be supervised
          # worker(Sequence.Worker, [arg1, arg2, arg3]),
        ]
    
        # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
        # for other strategies and supported options
        opts = [strategy: :one_for_one, name: Sequence.Supervisor]
        Supervisor.start_link(children, opts)
      end
    end

~~~

start  函数现在为我们的应用程序创建了一个supervisor。所有我们需要做的就是告诉他我们想要（监控 管理）
supervised什么。

## 在重启时管理进程状态

一些服务是无状态的。如果我们有一个服务，他计算数字的因子或者对一个网络请求以当前的时间进行响应，我们可以简单的重启他并让
其运行。

但我们的服务如果是非 无状态的--- 它需要记住当前的数字以便生成一个增长序列。这个问题的方法涉及到在进程外存储状态，让我们
选择一个简单的选项-- 我们可以写一个独立的工作者进程，他存储并取回一个值。我们可以称其为stash，sequence服务一旦终止，它可
以存储他的当前数字到stash，之后如果我们重启了可以恢复这个数字。

supervisor 树：
>
                        Mani Supervisor
                         /          \
                       /             \
                     /                \
                   /                   \
                Stash Worker           SubSupervisor
                                          |
                                          |
                                        Sequence Worker
 

## Supervisor 是可靠性的核心

代码中构建可信环（rings of confidence）.外部环，哪里我们的代码同世界交互，应该尽量使其可靠。但在环内部，有一些其他东西，
**嵌套环（nested rings）** ，在这些环中，事情可能不太完美，关键在于在这些环中保证代码在下个环down掉后 知道如何处理失败。

这就是supervisor扮演的角色。它有不同的策略用来处理子进程的终止，重启。


                                           
                                           

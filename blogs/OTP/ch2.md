GenServer 回调
========

GenServer 是一个OTP 协议，它假设我们自己的模块定义了一系列的回调函数，（GenServer 中是六个） 如果你用Erlang写了一个
GenServer你的代码必须包含这六个函数的回调实现。

当你给模块添加一行 use GenServer Elixir 会为你创建默认的六个函数实现，我们必须做的只是添加我们应用特定的行为，我们已经见了
两个了 handle_call 和 handle_cast 全部列表

- int(start_arguments)

- handle_call(request, from, state)

- handle_cast(request, state)
  响应GenServer.cast(pid, request),
  成功的响应是：{:noreply, new_state} 也可以返回 {:stop, reason, new_state} 
  默认的实现会用一个:bad_cast错误来停止Server
  
- handle_info(info, state)
  
- terminate(reason, state)
  当服务即将终止时调用，一旦我们为服务添加了supervision 我们就不必理会它了。
  
- code_change(from_version, state, extra)
  
- format_state(reason, [pdict, state])  


命名进程
=========

用pid引用进程的思想很快就过时了，幸而有其他的一些候选替换方案。

最简单的就是本地命名，为我们的服务上的OTP进程指定唯一的名称。其后可以用名称替代pid来引用他们。为了创建本地命名进程，我们
启动服务时使用name: 选项
GenServer.start_link(Sequence.Server, 100, name: :seq)
GenServer.call(:seq, :next_number)

一个OTP GenServer只是一个常规的Elixir进程，在进程里面他抽象出了消息处理。GenServer行为定义了一个内部的消息循环并维护了一
个状态变量，此消息循环之后调用不同的函数（我们在服务模块定义的：handle_call, handle_cast , 等）


    
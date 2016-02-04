Exceptions: raise and try catch and throw
==============

Elixir(同Erlang)采用这样的观点：errors应该通常对在其发生的进程中是致命的，典型的Elixir应用的的设计，涉及很多进程，意味着
错误的影响应该是局部化的。一个supervisor会探测到失败进程，之后会在那个级别处理重启的。

因为这个原因，你在Elixir程序中不会找到太多的exception-handling代码。Exception被激发，但你极少去catch他们。

#### 使用异常针对那些异常的事情 -- 那些永远也不应该发生的事情

异常确实存在，下面就看下如何生成他们 以及当他们发生时如何catch他们。

## Raising an Exception 触发一个异常
你可以触发一个异常 通过使用raise函数 ，最简单情况 你传递一个字符串 他会生成一个RuntimeError类型的异常。
>
    iex(10)> raise "Giving up"
    ** (RuntimeError) Giving up

你也可以传递异常的类型，伴随其他的可选字段，所有的异常至少实现message字段。
>    iex(1)> raise RuntimeError
     ** (RuntimeError) runtime error
>     
     iex(10)> raise RuntimeError, message: "override message"
     ** (RuntimeError) override message

你可以使用try函数来截获异常，他使用一个代码块来执行，可选的rescue，catch 和after字句。
rescue 和catch 字句看起来很像case函数的体部 -- 他们采用模式 当模式匹配时执行代码，模式的subject就是激发的异常。
~~~
    defmodule Boom do
        def start(n) do
            try do
                raise_error(n)
            rescue
                [ FunctionClauseError, RuntimeError ] ->
                    IO.puts "no function match or runtime error"
                error in [ArithmeticError] ->
                    IO.puts "Uh-oh! Arithmetic error: #{error.message}"
                    raise error, [ message: "too late, we're doomed "], System.stacktrace
                other_errors ->
                    IO.puts "Disaster! #{other_errors.message}"
                after
                    IO.puts "DONE!"
            end
        end
    
        defp raise_error(0) do
            IO.puts "No error"
        end
        defp raise_error(1) do
            IO.puts "About to divide by zero"
            1 / 0
        end
        defp raise_error(2) do
            IO.puts "About to call a function that doesn't exist"
            raise_error(99)
        end
        defp raise_error(3) do
            IO.puts "About to try creating a directory with no permission"
            File.mkdir!("/not_allowed")
        end
    end
~~~
我们定义了三个不同的异常模式，第一个匹配两个异常中的一个，FunctionClauseError 或者 RuntimeError ，第二个匹配ArithmeticError
并存储异常值到变量error中 ，最后一个可以捕获任何异常到变量other_error 。

我们也包含了一个after字句。这句应该总是运行在try函数的尾部，无论是否一个异常raise了。

最后，看下对ArithmeticError的处理，除了汇报error外 我们又调用了raise，传递了已经存在的异常单复写掉了他的消息。我们也传递
了堆栈栈迹（它实际是原始异常触发的那个点的栈迹）

### catch , exit , 和throw
Elixir代码(和底层Erlang库)可以触发第二类error 。当进程调用error,exit或者throw是生成。所有者三个接受一个参数，此参对catch
处理器可用。
这儿是一个例子:
~~~

    defmodule Catch do
        def start(n) do
            try do
                incite(n)
            catch
                :exit, code -> "Exited with code #{inspect code}"
                :throw, value -> "throw called with #{inspect value}"
                what, value -> "Caught #{inspect what} with #{inspect value}"
            end
        end
    
        defp incite(1) do
            exit(:something_bad_happended)
        end
        defp incite(2) do
            throw {:animal, "wombat"}
        end
        defp incite(3) do
            :erlang.error "Oh no!"
        end
    end
~~~
用1,2,3做参数调用start函数会导致一个退出，一个throw，或者一个错误被thrown ，只是用来示例通配模式匹配，我们处理最后一个情
况通过匹配任何类型到变量what 。
~~~

    iex(5)> Catch.start 0
    "Caught :error with :function_clause"
    iex(6)> Catch.start 1
    "Exited with code :something_bad_happended"
    iex(7)> Catch.start 2
    "throw called with {:animal, \"wombat\"}"
    iex(8)> Catch.start 6
    "Caught :error with :function_clause"
~~~
## 定义你自己的异常
Elixir中的异常只是基本的记录。你可以定义你自己的异常通过创建一个模块，在模块内，使用defexception 来定义异常中的不同字段，
和他们的默认值。因为你正在创建了一个模块，你也可以添加函数 --- 这些经常用来格式化异常字段为有意义的消息。

~~~
    
    defmodule KinectProtocalError do
        defexception message: "Kinect protocol error",
                     can_retry: false
    
        def full_message(me) do
            "Kinect failed #{me.message}, retriable: #{me.can_retry}"
        end
    end
    
    try do
        talk_to_kinect
    rescue
        error in [KinectProtocolError] ->
            IO.puts KinectProtocolError.full_message(error)
            if error.can_retry, do: schedule_retry
    end
~~~

## 现在忽略本篇？
Elixir 源码中由于mix工具的不包含异常处理器，Elixir编译器本身包含了总共五个(但它做了一些漂亮的事情)

如果你发现你自己定义了新的异常，问问你自己是否应该独立代码到单独的进程，毕竟，如果它出现错误，你不想独立他么？



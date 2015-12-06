-  if  and unless
-   cond (a multiway if)
-   case (a pattern-matching switch)
-   Exceptions
 
在Elixir中 我们写很多小的函数 并组合使用 监护子句 和 参数的模式匹配 来替换其他语言中的大部分控制流程

Elixir 代码 试着尽量声明式  而不是命令式

elixir 确实有一小挫 控制流结构 但应该尽量避免使用他们！

在开始使用控制流程前 最好考虑下可替换的函数式解决方案，当你写更多的函数代码而没有显示使用控制流程时 好处变得明显起来 ，
函数变得更短且更集中 。他们很易读，测试，并重用 。 

## if 和 unless
if 和其邪恶分身 unless 接受两个参数 ： 一个条件 和 一个关键字列表 ，其可以包括关键字 do: else: ,如果条件是真  if表达式
计算do: 键值关联的代码 否则 计算else: 代码 两个分支都可以缺席。

~~~[elixir]

        if 1 == 1 , do:  "true part" , else:  "false part"
        
        if 1 == 2 , do:  "true part" , else: "false part "
        
~~~
如同  函数一样 Elixir提供了一些语法糖 ，你可以写前面的例子如下方式：

~~~[elixir]
   
      if  1== 1 do
        "true part"
      else
        "false part"
      end
~~~      
        

~~~[elixir]

    unless 1==1  , do:
         "error" , else: "OK"
         
    unless 1== 2 ,do: "OK ",
        else: "error"
    # 另一形式
    unless 1 == 2 do
        "OK"
    else 
        "error"
    end
~~~
if 和 unless的值 是其表达式计算的值

cond
-------

cond 宏 

case 
-----------


Raising Exceptions
--------------

官方警告：  在Elixir中 异常不是控制流程结构 ！
其意图是在常规的操作中永不会发生的东西 。  
db 死了  ，或者名称服务器不响应了

使用 raise 函数来激发异常  最简单形式 ， 传递一个字符串 
~~~[elixir]
    
    iex(1)>  raise "Giving up"
    ** (RuntimeError) Giving up
~~~
也可以传递异常的类型

~~~[elixir]
    
    iex(1)> raise RuntimeError
    ** (RuntimeError) runtime error
    
    iex(1)> raise RuntimeError , message: "override message"
    ** (RuntimeError) override message
~~~

在 Elixir中 使用异常的机会会比其他语言中更少 。 设计哲学是 错误应该传递到外部 ，supervising进程

elixir 有常规的异常捕获机制
            
设计异常
--------

如果 File.open 打开成功 返回{:ok , file} file就是给你访问文件的服务 
如果失败 返回 {:error , reason} 

~~~
    
    case File.open(user_file_name)
    do
    {:ok , file} ->
     process(file)
     {:error, message} ->
     IO.puts :stderr , "Couldn't open #{user_file_name} : #{message}"
     end 
~~~
替代的 如果期望文件每次都打开成功 ，当失败时可以激发一个异常
            
~~~
    
    case File.open("config_file")
    do  
        {:ok , file}->
        process(file)
        {:error , msg} ->
            raise "Failed to open config file #{msg}"
        end     
~~~  
或者 让elixir 来激发异常：
~~~
    
    {:ok , file} = File.open("config_file")
        process(file)
~~~
如果第一行匹配失败 会触发MatchError 异常的

更好的使用方法是使用File.open!  （同其他函数一样）末尾的惊叹号指出 改函数在错误时会触发异常的，并且异常是有意义的
我们可以简写如下 来解放我们自己
~~~
    
    file = File.open!("config_file")
~~~
>  许多内建函数有两种形式 xxx 形式返回 一个元祖： {:ok, data}   和 xxx! 形式返回成功时的数据 ，但其他情形会触发异常。 
   然而 有一些函数并没有 xxx! 形式。

以更少的做更多的事
-----
elixir 只有恨少部分的控制流程： if unless cond case 或者 加上 raise 
但惊奇的是 实际并不是这样，Elixir没有很多的分支代码 ， 但程序更富有 表达力 ， 

            
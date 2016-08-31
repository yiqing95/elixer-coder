Elixir 的元祖允许我们把多个项目绑定到一个组合的数据类型上。这使得在组件间很容易传递消息。让你得以创建所需的复杂数据结构。

元祖可以包含任意复杂的Elixir数据 ： numbers , atoms, 其他元祖tuples  ， lists , string ...

大括号包起来：
{:earth, 10 , 10.1 , ... }

元祖可能包含一个项目，或可能100个，2到5个看起来比较典型(有用 可读) 经常（但不总是）一个元祖的开始元素显露其真正用途，提供一个存储在元祖中
复杂信息结构的非正式标识符。

elem 函数 来读取
put_elem 函数来设置值
tuple_size 获取总数
Elixir（不像erlang）从零开始计数。所以元祖中第一个元素是以0来引用，第二个是1 ，依次.
>
    iex(31)> tuple = {:earth, 10 }                                                                                                      
    {:earth, 10}                                                                                                                        
    iex(32)> elem(tuple, 1)                                                                                                             
    10                                                                                                                                  
    iex(33)> newTuple = put_elem(tuple, 1, 40)                                                                                          
    {:earth, 40}                                                                                                                        
    iex(34)> tuple_size(newTuple)                                                                                                       
    2                               

    
## 用元祖来模式匹配

元祖使得打包多个参数到一个单独的容器中很容易，让接受者函数决定如何处理它。在元祖上模式匹配跟在原子上模式匹配很像 ，除了大括号:) 。

>
    def fall_velocity({:earth , distance }) when distance >= 0 do :math.sqrt(2 * 9.8 * distance ) end

原先两个参数的版本 可以使用元祖来重写变为一个参数啦！

为啥要使用这种形式的版本，还要多敲大括号. 因为元祖打开了更多的可能性。其他代码可以打包不同的东西到元祖 --  更多的参数，不同的原子，甚至
使用fn() 创建的函数 。传递独个元祖而不是一排参数 使得Elixir更灵活 ，特别是在不同的进程间传递消息时。

##　处理元祖
有很多处理元祖的方法　不仅仅是简单的模式匹配。

如果你接收到一个元祖，最简单的是可以传递它到一个私有版的函数去。

~~~elixir 

    defmodule Drop do
        def fall_velocity({planemo, distance}) when distance >= 0 do
            fall_velocity(planemo, distance)
        end

        defp fall_velocity(:earth, distance) do
            :math.sqrt(2 * 9.8 * distance)
        end

        defp fall_velocity(:moon, distance) do
            :math.sqrt(2 * 1.6 * distance)
        end

        defp fall_velocity(:mars , distance) do
            :math.sqrt( 2 * 3.71 * distance)
        end
    end
~~~

元祖版本的是公共的 这种技巧：
    **让一个版本称为公共的，让其他拥有不同参数个数的函数保持私有**
比较通用 很适合在你希望一个函数可访问，但并不太想其内部对外可访问。

如果你调用这个函数--》元祖版的 ，大括号是必须的     


...

有不同的方式从元祖中提取元素，可以使用Kernel模块下的 elem/2 
> elem(t , 0 )
也可以做模式匹配 
{p1, p2 } = tuple_x

函数中最后一行的值 就是函数的返回值。




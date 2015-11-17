处理集合
============

-  Enum 模块
-   Stream 模块
-   Collectable 协议
-   Comprehension（推导）

Elixir有好多集合一样的类型，如lists dictionaries 
还有如：ranges（区间） ， files（文件），dictionaries，甚至functions 。

集合间的实现是不同的，但有一些共享东西：
比如可以迭代他们 
有一些共享trait：比如添加元素

技术层面说 能够被迭代的东西就是实现了 Enumerable 协议 。

Elixir提供了两个模块 具有一些迭代函数 
-  Enum模块 是集合的教养所 我们总是会用他们的
-  Stream 模块 让我们可以惰性（lazy）枚举一个集合。 洗衣歌值只有在需要他们时才会被计算。这个不是太常用
    但有时是你的救世主。

劲量的熟悉这些api（todo 去看api文档 gogogo！）    
Elixir的强大多来自于这些库

Enum
--------

此模块几乎所有的Elixir库都会用到的！用之，迭代 过滤 合并 分裂 或者其他的集合操作
这里有一些常见的：

-  转换任何集合到列表
    list = Enum.to_list  1..5  
-  集合连接
    Enum.concat([1,2,3] , [4,5,6])
    Enum.concat [1,2,3] , 'abc'
-  创建集合 其原素是原始原始的函数
     Enum.map(list, &(&1 * 10 )) # 每个元素统一乘10
     Enum.map(list , &String.duplicate("*",&1) )
-  通过位置或者某种条件来选择元素
     Enum.at(10..20 , 3)  # 13
     Enum.at(10..20 , 20)  # nil
     Enum.at(10..20 , 20 , :no_one_here) #:no_one_here
     
     Enum.filter(list , &Integer.is_even/1) # [2,4]
     
     Enum.reject(list , &Integer.is_even/1) # [1,3,5]
-    排序和比较元素
     Enum.sort(["there" , "was" , "a" , "crooked" , "man" ])
     Enum.sort(["there" , "was" , "a" , "crooked" , "man" ],&(String.length(&1)<= String.length(&2))) # 自定义排序函数
     
     Enum.max ["there" , "was" , "a" , "crooked" , "man" ]
     Enum.max_by ["there" , "was" , "a" , "crooked" , "man" ] , &String.length/1
     
-    分裂一个集合
     Enum.take(list, 3)
     Enum.take_every list , 2
     Enum.take_while(list , &(&1 < 4 ))
     
     Enum.split(list,3)
     Enum.split_while(list,&(&1 < 4 ))
     
-   join
     Enum.join(list)
     Enum.join(list ," , ")
-   断言 （predicate operation）
     Enum.all?(list, &(&1 < 4 ))           # 都小于4
     Enum.any?(list, &(&1 < 4))  # 只要一个小于4就是true啦
     
     Enum.member?(list , 4)]
     Enum.empty?(list)
     
-   合并（列列合并）
     Enum.zip(list,[:a,:b,:c])  # [{1,:a} ,{2,:b},{3,:c}
     Enum.with_index(["one","two"]) # [{"one", 0} , {"two",1}]
     
-   折合元素成一个值（fold 或者 reduce）
     Enum.reduce(1..100, &(&1+&2)) $ 5050
     
     Enum.reduce(["now","is","the","time"],fn word , longest -> 
                         if 
                            String.length(word) >
                            String.length(longest) do
                                    word
                         else
                            longest
                         end
                 end                                                              
     )
     
-    处理卡牌
     
~~~[elixir]
     
     import Enum
     
     deck = for rank <- '23456789TJQKA' , suit <- 'CDHS' , do:( [suit,rank] )
     
     deck |> shuffle |> take(13)
     
     hands = deck |> shuffle |> take(13) # 每手都不一样哦 随机的
     hands = deck |> shuffle |> take(13)
     hands = deck |> shuffle |> take(13)
~~~     
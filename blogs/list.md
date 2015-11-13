列表
-----------

列表或是空的 或者由 头跟尾组成（head  tail ）

空列表可以这样表示：  []

头与尾用 管道 符号 分割 : |

一个元素的列表：  [3]  可看做  head是3 尾是空列表的列表  [3 | [] ]
当看到管道符号时  我们说其左侧是 头 右侧是 尾

再比如： [2 , 3 ] 可写为 [2 | [3 | [] ] ]

 左侧添加元素：  [1 | [ 2 |  [ 3 |[] ] ] ]
                 [1   , 2   ,3 ]
                 
                 
在模式匹配中 模式可以是列表

[ head | tail ] = [1,2,3 ]             
    
## iex 解析字符串
    
字符串有两种形式 双引号 或者单引号括起来 的字符
    
    对于单引号 'cat'   看做整数码点组成的列表 : 99 ， 97 ， 116

但当看到 [ 99 , 97 , 116 ] 时 不清楚到底表示的是整数列表呢 还是 'cat' 
此时 它 用了启发式方法 如果列表中的值都是可打印的字符 就将之显示为一个字符串！

~~~[elixir]

        iex(1)> [ 99 ,97 ,116 ]
        'cat'
    
       iex(2)> [ 99 ,97 ,116 , 0 ] # 0 是不可打印字符 所以整个列表视为整数列表而不是字符串！
       [99, 97, 116, 0]
~~~
    
## 使用头和尾 来处理列表
    
我们可以把列表分为头和尾 我们可以用一个值跟一个列表构造一个列表 ，值将变为 新列表的 头 ，列表变为新列表的尾 。  
  
列表跟递归经常一起出现 如同fish跟chips
  
来看看 列表长度

-  空列表的长度是 0
-  列表的长度是 1 + 列表尾的长度
   
实现：

~~~[elixir]

    defmodule MyList do
      @moduledoc false
    
      def len([]) , do: 0
    
      def len([head | tail ]) , do: 1 + len(tail)
    
    end

~~~
    
最诡异的是 第二个len定义 len([head | tail ] ) 匹配任何非空的列表
    
编译上面的文件会报一个警告：
    >   my_list.ex:6: warning: variable head is unused
    
在上面的模块中并没有使用便利head，为了不再让编译器吵闹，所以可以用_  下划线 来忽略某些匹配。它扮演占位符的角色，也可以
在变量名前面冠以下划线。 这种技术可以关闭因没有使用变量而产生的警告 

~~~[elixir]

       def len([_head | tail ]) , do: 1 + len(tail)

~~~

## 使用head和Tail来构建列表

~~~[elixir]

      #  对某个整数的列表 返回一个新的列表 元素是原先响应位上的平方
      def square([]) , do: []
      #  递归
      def square([head|tail]) , do: [ head * head | square( tail ) ]
    
    
      # 对列表中的每个元素自身增1
      def add_1( [] ) , do: []
      def add_1([ head | tail ]) , do: [ head+1 | add_1(tail) ]

~~~
运行如：
>  
     iex(7)> c "my_list.ex"
     my_list.ex:1: warning: redefining module MyList
     [MyList]
     iex(8)> MyList.square []
     []
     iex(9)> MyList.square [2,3,5]
     [4, 9, 25]
     iex(10)> c "my_list.ex"
     my_list.ex:1: warning: redefining module MyList
     [MyList]
     iex(11)> MyList.add_1 []
     []
     iex(12)> MyList.add_1 [3,5,6]
    
## 创建 Map 函数
    
上面的例子中 看到一种模式 ，所有的功能实际都是第二个函数定义承担的 ，操作发生在head 上 然后递归作用到 tail之上 并产生新
的列表返回         **[  ( some_op_on( head ) )    |  recursive_call_self( tail )    ]**

我们将定义一个 Map 方法，他接受一个list列表 和 一个函数 作为参数 ，并返回一个新的列表 列表中的每个元素会被函数所变换（即
函数会作用于列表中的每一个元素之上）， 

~~~[elixir]

      ##  著名的 Map 函数
      def  map([], _func) , do: [] # 下划线开始的参数 _func 防止编译器警告 （未使用的变量）
      def  map([head | tail ] ,func) ,do: [ func.(head) | map(tail,func) ]

~~~

测试：
>    
    iex(14)> MyList.map []  , fn -> end # 注意空函数！ fn -> end 
    []
    iex(15)> MyList.map [3,4,5]  , fn el -> el+1  end
    [4, 5, 6]
    iex(16)> MyList.map [3,4,5]  , fn el -> el*el  end
    [9, 16, 25]
    iex(17)>
    iex(17)> MyList.map [3,4,5]  , fn el -> el > 2  end
    [true, true, true]
    iex(18)>
    
函数之上内置的类型，定义于 fn 和 end之间 。 上例中使用了 func.(param) 来调用函数！  
  
### 使用& 的函数替代形式 
>
      iex(18)> MyList.map [3,4,5]  , &(&1 + 1 )
      [4, 5, 6]
      iex(19)> MyList.map [3,4,5]  , &(&1 * &1 )
      [9, 16, 25]
      iex(20)> MyList.map [3,4,5]  , &(&1 > 2 )
      [true, true, true]
  
## 递归时 持续跟踪值
  
对列表中的元素求和 
  
不同对列表中每个原素都做变换的是此时 我们需要记忆 前面的求和结果
递归结构
  -  sum([]) -> 0
  -  sum([head | tail]) ->  <<total>> + sum(tail)
  
但我们并没有地方来记录total！！ 我们的目标是有一个不可变的状态，所以我们不能把值保存在全局变量或者模块属性中。
  
但是我们可以在函数参数中传递状态！
  
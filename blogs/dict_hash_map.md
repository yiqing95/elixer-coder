如何选择 Maps HashDicts Keywords
- 如果一个key 对应多余一个的条目(entry)  
    我们选择 Keyword 模块
    
- 是否需要保证元素有序
    如果是 使用 Keyword 模块

-   是否需要通过模式来匹配内容 （ 比如 匹配一个字典 其拥有一个  :name 的key ）
    如果是 使用 map
    
-   是否 存储成千上百的元素
    如果是 使用HashDict 
    
# 字典
    
Maps 和 hashdicts 都实现了Dict行为 。Keyword 模块当然也实现 ，但其有一些不同点 ，比如支持重复的keys 。
    
普遍情况 ，你会使用Dict 模块的方法来访问这些功能 ，这会允许你很灵活的替换掉实现（在他们见切换）比如map和hashdict。    


Keyword 列表 允许重复值出现，但必须使用Keyword模块来访问他们

## 模式匹配

对map的问题：
－　是否存在key为 :name 的条目
-   是否存在 key 为 :name 和 :height 的条目
-   key 为:name 的值是否是"YiQing" ?

在模式匹配中 map不允许绑定值到key上
可以这样：
> %{2 => state } = %{ 1=> :ok , 2=> :error }
    state #  :error 

而不是这样(编译错误)：%{ item => :ok } = %{ 1=>:ok , 2=:error }    

## 更新map

在elixir 中map也是不可变的 所以对map的更新也是返回一个新map！
最简语法： 
> new_map = %{ old_map | key => value , ... }

这会创建一个新的map 其是原来的拷贝 ，但管道右侧的 kv 对会更新掉老map中的东西 。

但这种语法不会添加新的key ！
添加key必须使用Dict.put_new/3 函数

## Maps 和 结构

%{ ... } 会被Elixir 视作map的 但也仅仅知道他是个map不会知晓更多

对于匿名maps 是很好的 ，自由的key，自由的类型 。

typed map： 拥有固定集合的字段和默认值 这样既可以在类型上也可以在内容上使用模式匹配 

### 进入struct领域

struct 模块 视为受限的map形式 
 之所以受限是因为，keys 必须是原子 ，不具有Dict和Access 的能力
 
模块的名称 将变为 map类型 的名称 ，在模块内部 使用defstruct 宏来定义map的特征 

~~~[elixir]

    defmodule Subscriber do
    
    defstruct name: "" , paid: false , over_18: true
    
    end

~~~
 
>
        $ iex defstruct.exs
        Eshell V7.0  (abort with ^G)
        Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
        iex(1)> s1 = %Subscriber{}
        %Subscriber{name: "", over_18: true, paid: false}
        iex(2)> s2 = %Subscriber{ name: "Yiqing", over_18:true}
        ** (SyntaxError) iex:2: keyword argument must be followed by space after: over_18:
>        
        iex(2)> s2 = %Subscriber{ name: "Yiqing", over_18: true}
        %Subscriber{name: "Yiqing", over_18: true, paid: false}
        iex(3)> s3 = %Subscriber{ name: "Yiqing", over_18: true, paid: true}
        %Subscriber{name: "Yiqing", over_18: true, paid: true}

创建结构的语法跟创建map的基本一样 只不过在% 和 { 之间加入了模块名称 。
访问结构的字段 可以使用 点 符号 或者使用 模式匹配

>
    iex(4)> s3.name
    "Yiqing"
    iex(5)> %Subscriber{name: a_name } = s3
    %Subscriber{name: "Yiqing", over_18: true, paid: true}
    iex(6)> a_name
    "Yiqing"
    iex(7)>

更新
>
    iex(7)> s4 = %Subscriber{ s3 | name: "yiqing001" }
    %Subscriber{name: "yiqing001", over_18: true, paid: true}
    
结构之所以用模块封装起来是因为 经常需要添加结构相关的行为
~~~[elixir]
    
    defmodule Attendee do
    
        defstruct name: "" , paid: false , over_18: true
    
        def may_attend_after_party( attendee = %Attendee{} ) do
            attendee.paid && attendee.over_18
        end
    
        def print_vip_badge( %Attendee{name: name} ) when name != "" do
            IO.puts "Very cheap badge for %{name} "
        end
        def print_vip_badge(%Attendee{}) do
            raise "missing name for badge"
        end
    
    endb

~~~    
>
      $ iex defstruct1.exs
      Eshell V7.0  (abort with ^G)
      Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
      iex(1)> a1 = %Attendee{ name: "Yiqing",over_18: true }
      %Attendee{name: "Yiqing", over_18: true, paid: false}
      iex(2)> Attendee.may_attend_after_party(a1)
      false
      
>
      iex(3)> a3 = %Attendee{}
      %Attendee{name: "", over_18: true, paid: false}
      iex(4)> Attendee.print_vip_badge(a3)
      ** (RuntimeError) missing name for badge
          defstruct1.exs:13: Attendee.print_vip_badge/1
          
结构在试下多态时也扮演了很重要的角色！
          
### 另一种访问结构的方式
          
使用点来访问结构可能感觉比较奇怪， 毕竟结构跟map 有很多相似点 我们是这样访问map的：
          some_map[:name]
原因是map实现了Access 协议（此协议 定义了使用中括号来访问字段的能力）
结构并没有实现它 。
但我们可以很容易的通过添加 @derive 指令 来使之具备这种能力

### 结构嵌套
          
~~~[elixir]

    defmodule Customer do
    
        defstruct name: "" , company: ""
    end
    
    defmodule BugReport do
    
        defstruct owner: %{} , details: "" ,
        severity: 1
    
    end   
~~~

>
    # 创建一个bug-report
    report = %BugReport{
        owner: %Customer{name: "Yiqing" , company: "UZ" } ,
        details: "broken",
    }

访问：          
> iex> report.owner.company       
    
更新：
> iex> report = %BugReport{ report | owner: %Customer{ report.owner | company: "WiTo" } }
    
这种语法看起来冗长 丑 易出错 难读

幸运的是 Elixir 有一些用于嵌套的字典访问函数 ，
> iex> put_in(report.owner.company , "WiTo")

这不是什么魔法 它只是一个宏 可以生成 冗长的代码 

对结构中的值应用一个函数：
> iex> update_in( report.owner.name , &("Mr." <> &1) )
     
其他几个如：
- get_in
- get_and_update_in 
这些方法都能进行 嵌套式访问 
### 嵌套访问器 与 非结构
嵌套访问器 使用了Access 协议     来剥离或者组装数据结构 

> iex> report = %{ owner: %{name: "yiqing" , company: "UZ"} , severity: 1 }
    put_in(report[:owner][:company] , "WiTo"  )
    pudate_in(report[:owner][:company] , &( "Mr. " <> &1  )   )
    
### 动态（运行期）嵌套访问器
迄今见到的都是宏 （在编译期操作），所以 有一些限制：
    -   对特定的调用传递的key数目是静态的
    -   不能在函数间 以参数的形式 传递 keys集合
宏 的天然特征就是在编译期 将参数 “烙” 入代码中    
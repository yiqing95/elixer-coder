# 宏

# 抽象语法树

为了掌握元编程， 你首先需要理解Elixir 代码内部被表示为Abstract Syntax Tree(AST) ,很多你所见的语言都是和AST协作的，只是你
经常不知道他们的存在。当你的成像被编译或者解析。在被转变为字节码或者机器码之前他们的源码被转换为一个树形结构。这个过程经
常被掩盖了，你甚至永远不需要知道这个。

Elixir是很特别的 作者选择把AST以语言自身的形式暴露出来，并给我们了一种很自然的语法何其交互，通过常规的Elixir代码，让AST
可访问让我们可以做很多强悍的事情，因为我们可以在通常只保留给编译器和语言设计者层面操作了。

Elixir中的元编程涉及操纵和审看AST ，你可以使用quote宏访问任何Elixir表达式的AST表示。代码生成很是依赖quote。

让我们看看一些基本的表达式的AST表示：
~~~

    iex(2)> quote do: 1+2
    {:+, [context: Elixir, import: Kernel], [1, 2]}
    iex(3)> quote do: div(10,2)
    {:div, [context: Elixir, import: Kernel], [10, 2]}
~~~
可看到AST表示了 1+2 和div例程 生成了简单的数据结构 用Elixir自己的terms
你可以访问你写的作为Elixir数据结构的任何代码表示。quoting表达式给你了你从不曾在一个语言中见到的某些东西：一种可窥视你的
代码内部表示的能力，在你知道和了解数据结构后，让你infermeaning，优化性能，或者扩展功能仍旧保持使用Elixir的高级语法。

~~~

    defmodule Math do
      @moduledoc false
      #{:+, [context: Elixir, import: Kernel] ,[5,2]}
      defmacro say({:+,_,[lhs,rhs]}) do
        quote do
          lhs = unquote(lhs)
          rhs = unquote(rhs)
          result = lhs + rhs
          IO.puts "#{lhs} plus #{rhs} is #{result} "
          result
        end
      end
    
      #{:*, [context: Elixir, import: kernel] ,[8, 3]}
      defmacro say({:*, _,[lhs, rhs]}) do
        quote do
          lhs = unquote(lhs)
          rhs = unquote(rhs)
          result = lhs * rhs
          IO.puts "#{lhs} times #{rhs}  is #{result}"
          result
        end
      end
    end

    iex(1)> c "math.ex"
    [Math]
    iex(2)> Math.say 5+2
    ** (CompileError) iex:2: you must require Math before invoking the macro Math.say/1
        (elixir) src/elixir_dispatch.erl:98: :elixir_dispatch.dispatch_require/6
    iex(2)> require Math
    nil
    iex(3)> Math.say 5+2
    5 plus 2 is 7
    7
    iex(4)> Math.say 18*4
    ** (FunctionClauseError) no function clause matching in Math.say/1
        expanding macro: Math.say/1
        iex:4: (file)
    iex(4)> Math.say 18 * 4
    ** (FunctionClauseError) no function clause matching in Math.say/1
        expanding macro: Math.say/1
        iex:4: (file)
    iex(4)> c "math.ex"
    math.ex:1: warning: redefining module Math
    [Math]
    iex(5)> Math.say 18 * 4
    18 times 4  is 72
    72
~~~

宏接受AST作为参数并提供AST作为返回值，通过书写宏，你可以用Elixir高级语法来构建AST。

宏接受我们传递给他的参数的AST表达式（参数先被解析为AST），我们然后用模式匹配在AST上来决定调用哪个say方法。
为了完成宏，我们使用quote来对调用者返回一个AST 来替换Math.say的调用。

##宏定义规则

- 不要写宏
   写代码来生成代码需要很小心。能用函数解决就不要写宏。
- 没必要用宏

## 抽象语法树揭秘
真正的理解AST 是通往高级元编程的基础，一旦你揭开这些细节，你会发现你的Elixir代码比你想象的更贴近AST。这种揭示会改变你
解决问题的思考方式并驱动你宏设计决策走的更远。

### AST的结构
每个你在Elixir中写的表达式在AST中会被解析为一个三元素的元祖，在宏中当使用模式匹配参数时会很依赖这种通用形式。
看个比较复杂的例子：
>
    iex(6)> quote do: (5*2) -1 + 7
    {:+, [context: Elixir, import: Kernel],
     [{:-, [context: Elixir, import: Kernel],
       [{:*, [context: Elixir, import: Kernel], [5, 2]}, 1]}, 7]}
       
    iex(7)> quote do
    ...(7)> defmodule MyModule do
    ...(7)>         def hello, do: "world"
    ...(7)> end
    ...(7)> end
    {:defmodule, [context: Elixir, import: Kernel],
     [{:__aliases__, [alias: false], [:MyModule]},
      [do: {:def, [context: Elixir, import: Kernel],
        [{:hello, [context: Elixir], Elixir}, [do: "world"]]}]]}
               
你可以看到从每个quoted表达式会生成一个元祖栈。
               
               
所以你在Elixir中写的代码都会被表示成这种通用结构，所有的Elixir代码被表示为一系列树元素元祖：
- 第一个元素是一个原子示出函数调用，或者是另一个元祖来表示AST中的内嵌节点
- 第二个元素表示表达式的元数据
- 第三个元素是函数调用的参数列表。

## 高级语法 VS 低级的AST
>
    Lisp:                       Elixir(去掉了元数据的干扰)
    (+ (* 2 3) 1)               quote do: 2 * 3 + 1
                                {:+, _, [{:*, _, [2,3]}]}

对比Elixir的AST和List的源码，发现如果用括号替换掉方括号结构基本相等，Elixir之美在于从高级源码转换到低级的AST只需要一个简
单但quote调用，使用List，你拥有所有可编程的AST的能力，损伤的只是一些自然和灵活的语法，在Elixir中，你同时拥有另个世界：
可编程的AST和一个高级的语法来执行所有的工作。

## AST 字面表达
当quoted时返回自身的：
>
    iex> quote do: :atom
    :atom
    iex> quote do: 123
    123
    iex> quote do: 3.14
    3.14
    iex> quote do: [1, 2, 3]
    [1, 2, 3]
    iex> quote do: "string"
    "string"
    iex> quote do: {:ok, 1}
    {:ok, 1}
    iex> quote do: {:ok, [1, 2, 3]}
    {:ok, [1, 2, 3]}

包括：atoms ，integers，floats,lists,strings,和任何量元素（包含前面提出的类型）的元祖 。
                               
如果将这些传递给宏，宏会接受的是字面参数而不是抽象表达了（那个三元素的元祖）
如果quote了其他类型你就会看到抽象形式被返回：
>   
    iex> quote do: %{a: 1, b: 2}
    {:%{}, [], [a: 1, b: 2]}
    iex> quote do: Enum
    {:__aliases__, [alias: false], [:Enum]}
                                   
某些值传递后原封不动，有的复杂类型会返回成quoted表达式，最好记住AST 字面表达形式 这样避免混淆宏参数的形式（是否是抽象形
式）。
                                  
## 宏 ：Elixir的构建块（单元）

重新实现unless宏
~~~

     defmodule ControlFlow do
     2 defmacro unless(expression, do: block) do
     3 quote do
     4 if !unquote(expression), do: unquote(block)
     5 end
     6 end
     7 end 
~~~     
为了使用宏先 require ControlFlow

因为宏接受参数的AST表示，我们可以接受任何有效的Elixir表达式作为第一个参数给unless ，第二个参数 ，可以用模式匹配在提供的
do/end 块上，并绑定其AST值给一个变量。
记住，一个宏的目的就是接受一个AST表示并返回一个AST表示，所以我们理解开始了quote并返回一个AST
在quote中，我们执行了一行代码生成，转换unless关键字到if! expression;
>   
    quote do
        if !unquote(expression), do: unquote(block)
    end
    
此转换被称之为宏展开，最后的从unless的AST返回值在编译期 在调用者的上下文中被扩展，最后生成的代码中将包含if ! expression
这些地方就是unless出现的任何地方（代码替换！）。             
                                
## unquote
unquote 宏允许值被注入进一个AST中，你可以认为quote/unquote是对代码的字符串篡改，如果你构建一个字符串并需要注入变量的值
到字符串中，你可以篡改（interpolate）它，构造一个AST也类似，我们使用quote来开始生成一个AST，并且使用unquote从外部上下文
注入值，这运行外部绑定变量，表达式，和block块。

我们可以使用Code.eval_quoted 来直接计算一个AST并返回其值。
>
    iex(10)> number = 5
    5
    iex(11)> ast = quote do
    ...(11)> number * 10
    ...(11)> end
    {:*, [context: Elixir, import: Kernel], [{:number, [], Elixir}, 10]}
    iex(12)> Code.eval_quoted ast
    ** (CompileError) nofile:1: undefined function number/0
        (stdlib) lists.erl:1353: :lists.mapfoldl/3
        (elixir) lib/code.ex:200: Code.eval_quoted/3
    iex(12)> ast = quote do
    ...(12)> unquote(number) * 10
    ...(12)> end
    {:*, [context: Elixir, import: Kernel], [5, 10]}
    iex(13)> Code.eval_quoted ast
    {50, []}

看到第一个次number的问题 他从一个局部变量number来引用，结果在计算时抛出一个未定义错误。为了纠正这个问题，我们使用unquote
注入number到 一个quoted上下文中 。

伴随有unquote 我们有了另一个基本的元编程工具。
quote和unquote 宏组合让我们手动构建AST不会太笨拙。

## 宏展开
让我们深入看看Elixir内部在编译期对宏到底发生了什么。当编译器遇到一个宏时，它递归展开代码知道代码不在包含任何宏调用。


## 代码注入和调用者上下文
宏不仅为调用者生成代码，他们注入它，我们把代码被注入的地方是一个上下文。 一个上下文是调用者的绑定，导入，和别名的域(scope)
对宏的调用者，上下文是很珍稀的，它持有世界的视图，不变性的好处，你不期望你的变量导入，和别名变掉

Elixir宏在保护你上下文上做了很好的平衡。

### 注入代码
因为宏的所有东西就是关于代码注入。所以你必须理解宏执行的两个上下文，不然你会面临在错误地方生成代码的风险。
一个是宏定义的上下文，另一个是调用者执行宏的。
~~~

    defmodule Mod do
        defmacro definfo do
            IO.puts "In macro's context (#{__MODULE__})."
    
            quote do
                IO.puts "In macro's context (#{__MODULE__})."
    
                def friendly_info do
                    IO.puts """
                    My name is #{__MODULE__}
                    My functions are #{inspect __info__(:functions)}
                    """
                end
            end
        end
    end
    
    defmodule MyModule do
        require Mod
        Mod.definfo
    end
    
    iex(1)> c "callers_context.exs"
    In macro's context (Elixir.Mod).
    In macro's context (Elixir.MyModule).
    [MyModule, Mod]
    
    iex(2)> MyModule.friendly_info
    My name is Elixir.MyModule
    My functions are [friendly_info: 0]
    
    :ok
~~~
可以看到在当模块便于时我们进入了调用者上下文和宏上下文，在宏展开之前我们进入了definfo上下文，接下来我们生成的AST在MyModule中
被展开，在那里IO.puts 直接注入到模块的体中随friendly_info 函数定义一起。

如果你发现你不能追踪你的上下文，经常是你代码生成太复杂的信号，此时最好保证宏定义尽量短和直接 以此来避免混淆。

## Hygiene Protects the Caller's Context
Elixir有个macro hygiene 的概念，Hygiene意味 你在宏中定义的 变量，导入 和别名 不会渗透到调用者自己的定义中。当做代码展开时
我们必须特别考虑macro hygiene。

## 重载 Hygiene
可以用var! 宏在quoted表达中来显式的重载hygiene


~~~

    defmodule Setter do
        defmacro bind_name(string) do
            quote do
                name = unquote(string)
            end
        end
    end
    
    iex(4)> require Setter
    nil
    iex(5)> name = "yiqing"
    "yiqing"
    iex(6)> Setter.bind_name("Hello")
    "Hello"
    iex(7)> name
    "yiqing"
~~~
name 变量并未被碰触 因为hygiene保护调用者的域。
我们可以使用var! 来允许我们的宏去产生一个AST 在展开时 其具有访问调用者绑定的权限。
~~~
    
    defmodule Setter do
        defmacro bind_name(string) do
            quote do
                var!(name) = unquote(string)
            end
        end
    end
    
    
    iex(8)> c "setter2.exs"
    setter2.exs:1: warning: redefining module Setter
    [Setter]
    iex(9)> require Setter
    nil
    iex(10)> name = "Yiqing"
    "Yiqing"
    iex(11)> Setter.bind_name("Max")
    "Max"
    iex(12)> name
    "Max"
~~~
通过使用var! 我们能够复写hygiene来重绑定name到一个新值，复写hygiene在某些场景时有用的，但应该尽量避免。
因为它掩盖了实现细节并添加了调用者不知道的隐式行为。只有在绝对需要时才选择性地复写hygiene。

当使用macros 知道其执行上下文是很重要的
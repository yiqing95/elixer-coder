为我们的代码添加抽象层，让代码更容易的与之交互。

micros（让我们可以扩展运营的语法），protocols(给已经存在的模块添加行为)，use（给一个module添加功能）

## micro 与 代码执行
你是否曾感到失望 因为一个语言不具有某些特性 对你正在写的代码？或者 你是否感到你自己在重复一下代码块（不能通过修改重构为
函数哟！），或者你只是希望你自己的程序能够离你的问题域更近些。

开始之前先警告： macros 可能很容易使得你的代码难于理解，因为你基本重写了语言的某些部分，因此 当你能够使用函数时就不要用
macro！

## Recipe 1： 当你可以使用一个函数时就不要使用宏
实际上，你可能不会在常规应用代码中写宏的。但如果你在写一个库并且想使用其他元编程技术 ，你就需要知道宏是如何工作的。

### 实现if语句
让我们假设Elixir 不具有if语句 --- 仅有的只是case 。尽管我们准备放弃我们的老朋友while循环 ，没有if语句还是会很难受的，所以
我们实现一个：
我们想以类似下面的方法调用它：
myif condition do
    evaluate if true
else
    evaluate if false
end

我们知道在elixir中块被转换为关键字参数，所以这等价于：
myif condition,
    do: evaluate if true ,
    else: evaluate if false
调用例子：
>   My.myif 1==2, do: (IO.puts "1 == 2") , else: (IO.puts "1 != 2")    

让我们试着以函来实现myif:
~~~
    
    defmodule My do
      @moduledoc false
    
      def myif(confition, clauses) do
        do_clause = Keyword.get(clauses, :do, nil)
        else_clause = Keyword.get(clauses, :else, nil)
        case condition do
          val when val in [false,  nil]
            -> else_clause
          _otherwise
              -> do_clause
           end
      end
    
    end

~~~

## Macros Inject Code 宏注入代码
让我们假装是Elixir编译器，我们从顶至底读入模块的源码并生成找到代码的表现，这些表现是嵌套的Elixir 元祖

如果我们想支持宏，我们需要一种方法告诉编译器： 我们想操作一部分元祖。我们使用defmacro ，quote 和unquote 来做这件事，

和def定义一个函数一样，defmacro定义一个宏，真正的魔法开始于我们使用宏而不是定义一个宏的时候。
当我们传递参数给宏时，Elixir并不会计算他们，换之，他以元祖形式表现他们的代码传递参数。我们可以检查这种行为通过一个简单的
宏定义（打印其参数）
~~~

    defmodule My do
        defmacro macro(param) do
            IO.inspect param
        end
    end
    
    defmoudule Test do
        require My
        # These values reprtesent themselves
         My.macro :atom #=> :atom
         My.macro 1      #=>  1
         My.macro 1.0
         My.macro [1,2,3] #=> [1,2,3]
         My.macro do: 1   #=> [do: 1]
         My.macro do
            1
            end           #=>  [do: 1]
         # And these are represented by 3-element tuples
        My.macro {1,2,3,4,5} #=> {: "{}" ,[line: 20] ,[1,2,3,4,5]}
    
        My.macro do: (a=1; a+a) #=>
        #  [do:
        #      {:__block__,[],
        #           [{:= ,[line: 22], [{:a ,[line: 22],nil },1] },
        #             {:+, [line:22] , [{:a,[line:22],nil},{:a,[line:22],nil}]}]}]
        My.macro do #=> [do: {:+,[line: 24],[1,2]},else: {:+,[line: 26],[3,4]}]
            1+2
         else
            3+4
         end
    end
~~~

此例展现给我们： 原子，数字 ，列表（包括关键字列表），二级制，两元素的元祖内部的自我表现形式，所有其他的Elixir代码被表示
为一个树元素元祖。至此，内部的表现对我们而言不是太重要。

### 加载顺序
上例中 你可能对代码结构有些好奇，我们在一个模块中定义了宏 ，在另一个模块中使用此宏，第二个模块中包含了 require 调用。

宏在程序执行前会被展开，所以在一个模块中定义的宏必须当Elixir编译另一个使用宏的模块时是可用的。require函数 告诉Elixir
在当前模块前确保命名的模块被编译了，实战中用来在一个模块定义的宏对另一个模块可用。
但两个模块的列子不是太清楚，实际情况是Elixir首先编译源文件之后运行他们。

如果我们是每模块一个源文件，我们引用一个A文件中的模块在文件B中，Elixir会从A中加载那个模块。所有的东西都工作正常，但是如果
我们有一个模块 使用它的代码在同一个文件中，并且模块通使用它的代码在同一个域中定义。Elixir就会不知道加载模块的代码，会得到
错误的
>  ** (CompileError)
    .../dumper.ex: 7:
    module My is not loaded but was defined, This happens because you 
    are trying to use a module in the same context it is defined . Try
    defining the module outside the context that requires it .

通过替换代码 使用模块My的模块到一个独立模块中，我们强制My被加载。
### Quote 函数
我们已经看到当传递参数给宏时，他们并没有被计算，语言中有一个函数 quote 他强制代码保持其未被计算的形式。quote接受一个block
块并返回块的表现形式。

~~~
    
       iex(14)> quote do: :atom
       :atom
       iex(15)> quote do: 1
       1
       iex(16)> quote do: [1,2,3]
       [1, 2, 3]
       iex(17)> quote do: "binaries"
       "binaries"
       iex(18)> quote do: {1,2}
       {1, 2}
       iex(20)> quote do: {1,2,3,4,5}
       {:{}, [], [1, 2, 3, 4, 5]}
       iex(21)> quote do: (a =1 ; a+a)
       {:__block__, [],
        [{:=, [], [{:a, [], Elixir}, 1]},
         {:+, [context: Elixir, import: Kernel],
          [{:a, [], Elixir}, {:a, [], Elixir}]}]}
       iex(22)> quote do: [do: 1 +2 ,else: 3+4 ]
       [do: {:+, [context: Elixir, import: Kernel], [1, 2]},
        else: {:+, [context: Elixir, import: Kernel], [3, 4]}]          
~~~   
有另一种方式来思考quote ，当我们写了"abc" 我们创建了包含字符串的一个二进制，双引号说"interpret what follows as a string 
of characters and return the appropriate representation."

quote 类似：他说"interpret the content of the block that follows as code, and return the internal representation"

### Using the Representation As Code 像代码一样使用表现
当我们析取一些代码的内部表现（无论通过宏或者quote函数）我们停止了在编译时Elixir自动添加他们到其构建的代码元祖中 -- 我们
创建了一个高效自由表现的代码，我们如何将这段代码注入回我们程序的内部表示。

有两种方法

第一种式 我们的老朋友macro 通函数一样，宏的返回值是宏中最后一个被计算的表达式。那个表达式是在Elixir内部表现的代码片段。
但Elixir没有返回这部分表现给调用宏的代码。换之他注入这段代码到我们的程序的内部表现中并返回给调用者代码执行的结果。但执行
只发生在需要的地方。

~~~
   
    defmodule My do
        defmacro macro(code) do
            IO.inspect code
            code
        end
    end
    
    defmodule Test do
        require My
        My.macro( IO.puts("hello") )
    end
    
~~~
我们会改变文件返回不同的代码片段，使用quote来生成内部形式:
~~~

    defmodule My do
        defmacro macro(code) do
            IO.inspect code
            quote do: IO.puts "Different code"
        end
    end
    
    defmodule Test do
        require My
        My.macro( IO.puts("hello") )
    end
~~~
即使我们传递 IO.puts("hello")做为参数 ，它也不会被执行，换之 使用quote的代码片段被返回

开始写我们自己版的if之前，我们还需要一个小技巧 -- 替换已有代码到一个quoted block中的能力 。有两种方法:通过使用unquote函数
和绑定。

### Unquote 函数
指出亮点，一 ，我们只能在quote块中使用unquote ，二 unquote是个傻名字，应该命名为 inject_code_fragement .

让我们看看为什么需要他：
~~~
    
    defmacro macro(code) do
        quote do
            IO.inspect(code)
        end
    end
~~~
不幸的是 当我们运行它是，报错了：
> ** (CompileError) .../eg2.ex:11: function code/0 undefined 

在quote块颞部，Elixir只是解析常规代码。 但我们希望Elixir 插入我们传递的计算后代码 ，此处应使用unquote ，它临时关闭了quoting
并简单的插入代码段到代码序列（quote返回的代码序列中）。

~~~

    defmodule My do
        defmacro macro(code) do
            quote do
                IO.inspect(unquote(code))
            end
        end
    end
~~~

在quote块内，Elixir忙于解析代码并生成其内部表现，但当其遇到unquote时，他停止解析并简单的拷贝代码参数到生成后的代码中，在
unquote后，有回到常规的解析过程。

有另一种方式来看待此事，在quote内部使用unquote是一种延迟执行unquoted code的方式。只有在quoted块被解析时才会运行的。换言之
当通过quote块执行生成代码时他才运行。

或者我们也可以同 quote-as-string-literal 那样想 "sum=#{1+2}" ,Elixir 计算1+2 并篡改结果到quoted的字符串中。
 但我们这样写：quote do: def unquote(name) do end ，Elixir串改name的内容到其构建的代码表示中（作为列表的一部分）
 
### 展开列表 -- unquote_splicing
 考虑下面的代码：
>   Code.eval_quoted(quote do: [1,2,unquote([3,4 ])]) 
    {[1, 2, [3, 4]], []}

[3,4]作为列表插入到整个quoted 列表中 ，结果是 [1,2,[3,4]].
如果我们只是想插入列表的元素，我们可以使用unquote_splicing.
>
    iex(24)> Code.eval_quoted(quote do: [1,2,unquote_splicing([3,4])] )
    {[1, 2, 3, 4], []}
还记得单引号字符串是字符的列表么，这意味我们可以这样写：
>   
    iex(25)> Code.eval_quoted(quote do: [?a , ?= ,unquote_splicing('1234')])
    {'a=1234', []}

## 回到我们的myif宏实现
至此我们已经可以实现自己的if了

~~~
    
    defmodule My do
        defmacro if(condition , clauses) do
            do_clause = Keyword.get(clauses, :do ,nil)
            else_clause = Keyword.get(clauses, :else, nil)
            quote do
                case unquote(condition) do
                    val when val in [false, nil] -> unquote(else_clause)
                    _                ->unquote(do_clause)
            end
        end
    end
    
    end
    
    defmodule Test do
        require My
        My.if 1==2 do
            IO.puts "1 == 2"
        else
            IO.puts "1 != 2"
        end
    end
~~~                
if宏接受一个条件和关键字列表。条件和在关键字列表中的任何入口条目作为代码段传递。
宏从列表中析取do: 或 else:子句 ，   
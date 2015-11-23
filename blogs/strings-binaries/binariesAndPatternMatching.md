
二进制第一准则：
    如果不确定为每个字段指定类型 ， 可用的类型：binary，bits ，bitstring ， bites，float ， integer ,utf8 ,utf16,
    utf32 . 也可以加后置修饰（qualifiers）：
    -  size(n)
    -  signed 或者  unsigned
    -  endianess： big ， little， 或者 native  
    使用连字符来分割多个字段
    
~~~[elixir]
   
    <<  length::unsigned-integer-size(12), flags::bitstring-size(4) >> = data 
    
~~~    

除非从事的工作多跟 二进制文件 或者协议格式 相关的
我们多处理的是utf-8字符串

当处理列表时 ，我们用模式 分割列表（一个head 和余下的list） 


类似 我们处理二进制的字符串时 也可如此，不得不指定head的类型（utf-8），并确信剩余的尾部（tail） 依旧是二进制。

~~~[elixir]
    
    defmodule Utf8 do
    
        def each(str, func) when
        is_binary(str) , do:
        _each(str,func)
    
        defp _each(<< head :: utf8 , tail :: binary >> , func) do
            func.(head)
            _each(tail,func)
        end
    
        defp _each(<<>> , _func) , do: []
        
    end
~~~
类比 list
-  [head | tail ]              <<  head::utf8 , tail::binary >>
-  []                          <<>>  


## 常见但奇怪
字符串处理在elixir中 是底层ERlang环境长期革命性处理的结果
如果我们从头开始做，事情看起来可能有点不一样，但一旦我们克服这个稍显怪异的处理方式（字符串是使用二进制匹配来做的！），你会
发现它工作的很好，特别地 模式匹配使得在字符串中查找特定序列开始的字符串很容易写 进而使我们解析任务也很好做。

我们在elixir中很少用控制流程的结构：if case 等 比其他传统语言要少！

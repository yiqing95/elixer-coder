当代码量增加时  单纯的几行代码已经不能满足我们的要求了

此时我们会封装自己的函数 将其组织到模块中

函数有匿名跟命名函数两种 

命名函数必须出现在一个module模块中 

## 模块

模块名称必须要首字大写哦！

~~~[elixir]

    defmodule Times do
      @moduledoc false
    
      def double(n) do
         n*2
      end
      
    end

~~~

模块代码写好后 需要我们编译这个文件 比如在iex中使用

        iex times.exs
        -- iex times.ex
        iex>  Times.double 4 # 调用我们自己的模块哦！
        
如果我们已经在iex环境中 我们可以使用
        
        c "times.exs" 
c 编译指令会编译times文件中的源码 并将之加载到iex中的

        
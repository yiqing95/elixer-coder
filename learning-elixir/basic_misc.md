map 函数 
接受一个函数和一个列表，并作用函数到列表的每个元素上。

~~~
    
    defmodule MyMap do
        def map([], _) do
            []
        end
    
        def map([h|t], f) do
            [f.(h) | map(t, f)]
        end
    end
    
    square = fn x -> x * x end
    # MyMap.map(1..5, square)
    MyMap.map([1,2,3,4,5], square)
~~~


并发版：
~~~ 
        
        defmodule Parallel do
            def pmap(collection, func) do
                collection
                |> Enum.map(&(Task.async(fn -> func.(&1) end )))
                |> Enum.map(&task.await/1)
            end
        end
~~~

## Elixir files Elixir文件
Elixir 使用两种文件 .ex用于编译代码 .exs用于脚本。
必须都是UTF-8 编码，   

在iex中我们可以使用import_file/1 来导入和加载我们的脚本
>
    iex(2)> h(import_file/1)
    iex   > import_file "~/file.exs"
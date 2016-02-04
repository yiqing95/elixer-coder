高级编译期代码生成
=============

通过高级元编程， 我们可以从外部信息源直接嵌入数据和行为到模块

从外部数据生成函数
-----------
标准库的String.Unicode 模块 在编译的时候 从外部数据 动态生成成千上万的函数定义 。

UnicodeData.txt 代码片段;
~~~
    ...
    00C7;LATIN CAPITAL LETTER C WITH CEDILLA;Lu;0;L;0043 0327;...
    00C8;LATIN CAPITAL LETTER E WITH GRAVE;Lu;0;L;0045 0300;...
    00C9;LATIN CAPITAL LETTER E WITH ACUTE;Lu;0;L;0045 0301;...
    00CA;LATIN CAPITAL LETTER E WITH CIRCUMFLEX;Lu;0;L;0045 0302;...
    00CB;LATIN CAPITAL LETTER E WITH DIAERESIS;Lu;0;L;0045 0308;...
    ...
~~~
此文件包含两万七千行这种分号分割的码点映射（code-point mappings） String.Unicode 模块在编译期打开此文件 并解析码点为函数
定义，最终的展开包含一个函数定义（每个码点对应一种转换和其他字符串转换）

~~~

    defmodule String.Unicode do
    ...
    def upcase(string), do: do_upcase(string) |> IO.iodata_to_binary
    ...
    defp do_upcase("é" <> rest) do
    :binary.bin_to_list("É") ++ do_upcase(rest)
    end
    defp do_upcase("ć" <> rest) do
    :binary.bin_to_list("Ć") ++ do_upcase(rest)
    end
    defp do_upcase("ü" <> rest) do
    :binary.bin_to_list("Ü") ++ do_upcase(rest)
    end
    ...
    defp do_upcase(char <> rest) do
    :binary.bin_to_list(char) ++ do_upcase(rest)
    end
    ...
    end
~~~
编译的模块包含成千上万个这种定义！当转换字符串"Thanks Jose"到大写时，String.Unicode 简单的调用do_upcase/1 递归地在字符串
中对每个code point ，当碰到某个字符"e" 对应（匹配）此码点的生成的函数并返回大写版本。

通过使用Erlang虚拟机的模式匹配引擎，Elixir获得了字符串操作的高性能
这种方式的好处是当新unicode字符加入时只需更新UnicodeData.txt 之后运行 mix compile 即可

十行代码的MIME-Type 转换
----------

如果你层写过web service 你很可能需要验证 或者根据文件扩展转换MIME类型。比如，当一个请求来到server 伴随一个Accept header
application/javascript 我们必须知道如何处理此MIME类型并渲染一个.js模板。为了处理这个问题 在多数语言中，我们需要存储MIME数据
在一个map中并询问keyspace 用于MIME类型转换。

使用已经存在的数据集
------------

首先我们需要找到一个MIME-type数据集作为我们实现的基础。通过internet搜索一个格式化比较好些的 MIME-type文本文件。
mime.txt文件的片段
~~~

    application/javascript .js
    application/json .json
    image/jpeg .jpeg, .jpg
    video/jpeg .jpgv
~~~
全部的文件包含685行 映射标准MIME类型到其文件扩展。为了解析此文件，我们通tab和comma分隔每行来获取MIME类型和文件扩展。
让我们来定义一个Mime模块用mimes.txt来执行转换。
~~~

    defmodule Mime do
        for line <- File.stream!(Path.join([__DIR__, "mimes.txt"]), [], :line) do
            [type, rest] = line |> String.split("\t") |> Enum.map(&String.strip(&1))
            extensions = String.split(rest, ~r/,\s/)
    
            def exts_from_type(unquote(type)) , do: unquote(extensions)
            def type_from_ext(ext) when ext in unquote(extensions), do: unquote(type)
        end
    
        def exts_from_type(_type), do: []
        def type_from_ext(_ext), do: nil
        def valid_type?(type), do: exts_from_type(type) |> Enum.any?
    end
~~~

考虑下面的代码段
~~~
    
    defmodule Fragments do
        for {name, val}  <- [one: 1, two: 2, three: 3] do
            def unquote(name)(), do: unquote(val)
        end
    end
    
    IO.puts Fragments.one
    IO.puts Fragments.two
    IO.puts Fragments.three
    
    # IO.puts Fragments.notExist
~~~
使用unquote 代码段来动态定义函数。
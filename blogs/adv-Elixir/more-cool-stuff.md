Elixir打包了一些使得编码更具乐趣的特性

## Writing Your Own Sigils
已知你可以创建字符串和正则表达式 使用魔术符
>   
    string = ~s{now is the time}
    regex =  ~r{..h..}

你是否也曾想过扩展这些魔术符添加你自己的特殊字面类型？ 你可以的！

当你写了一个类似~s{...}的魔术符 Elixir将之转换为调用函数sigil_s ,它床底给函数两个值，第一个是位于定界符之间的字符串，第二
是一个列表包含任何其后紧跟着结尾定界符的小写字符。（第二个参数用来挑拣任何你传递给正则字面符号的选项如 ~r/cat/if.）

这里是一个魔术符 ~l 的实现 ，他接受一个多行字符串并返回一个列表 包含其中的每行作为独立字符串。我们知道 ~l...
被转换为调用sigil_l, 所以我们只需要写个简单的函数在LineSigil模块中
~~~
    
    defmodule LineSigil do
        @doc """
            Implement the `~l` sigil, wich takes a string containing
            multiple lines and return a list of those lines .
            ## Exaple usage
            iex> import LineSigil
            nil
            iex> ~l'''
            ...>  one
            ...>  two
            ...>  three
            ...>  '''
            ["one","two","three"]
        """
        def sigil_l(lines, _opts) do
            lines |> String.rstrip |> String.split("\n")
        end
    end
    
    defmodule Example do
        import LineSigil
        def lines do
            ~l"""
            line 1
            line 2
            and another line in #{__MODULE__}
            """
        end
    end
    
    IO.inspect  Example.lines
    
    iex(1)> c("line_sigil.exs")
    ["line 1", "line 2", "and another line in Elixir.Example"]
    [Example, LineSigil]

~~~
因为我们在example模块中导入了sigil_l 函数，~l 魔术符只在当前模块的语法域中。

预定义的符号函数：sigil_C , sigil_c, sigil_R, sigil_r , sigil_S , sigil_s, sigil_W 和sigile_w. 如果你需要复写他们中的某个
你需要显式导入Kernel模块 并使用except字句排除它们 。

此列中我们使用了heredoc 语法 （"""） . 这传递给我们函数多行字符串 其头部的空格被移除。sigil options 不支持heredocs。所以
我们将切到常规字面语法去。

### Picking Up the Options
让我们写一个sigil 他使得我们指定一个颜色常量，如果我们说~c{red},我们得到 0xff0000 ， RGB表示 。我们也支持选项h来返回HSB值
，因此 ~c{red}h 会得到{0, 100, 100}
~~~

    defmodule ColorSigil do
        @color_map [
            rgb: [red: 0xff0000, green: 0x00ff00, blue: 0x0000ff , # ...
            ],
            hsb: [red: {0,100,100} , green: {12,100,100},blue: {240,100,100}
            ]
        ]
    
        def sigil_c(color_name,[]), do: _c(color_name, :rgb)
        def sigil_c(color_name, 'r'), do: _c(color_name, :rgb)
        def sigil_c(color_name, 'h'), do: _c(color_name, :hsb)
    
        defp _c(color_name, color_space ) do
            @color_map[color_space][binary_to_atom(color_name)]
        end
    
        defmacro __using__(_opts) do
            quote do
                import Kernel, except: [sigil_c: 2]
                import unquote(__MODULE__), only: [sigil_c: 2]
            end
        end
    
    end
    
    defmodule Example do
        use ColorSigil
        def rgb, do: IO.inspect ~c{red}
        def hsb, do: IO.inspect ~c{red}h
    end
    
    Example.rgb
    Example.hsb
~~~

我们覆盖了内部的sigil 实现__using__ 宏 它自动移除Kernel中的版本添加我们自己的（仅限我们调用use的模块中  的语法域中）

虽然我们可以写出我们自己的 ， 但请勿滥用sigil哦


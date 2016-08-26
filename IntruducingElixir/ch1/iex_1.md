iex

**  iex 下面可以敲linux下的常用命令

~~~shell

    iex(4)> pwd
    f:/Elixir-workspace/elixer-coder
    :ok
    iex>  ls
    ...
    iex(5)> cd "intruducingElixir"
    f:/Elixir-workspace/elixer-coder/intruducingElixir
    :ok
    iex(6)> pwd
    f:/Elixir-workspace/elixer-coder/intruducingElixir
    :ok

~~~
这些os 命令基本是做为函数形式出现的！
>
    iex(9)> cd("intruducingElixir")
    f:/Elixir-workspace/elixer-coder/intruducingElixir
    :ok

由于函数的调用形式 在elixir中可以 去掉括号所以 形式   f(p)  ==>  f  p


## iex 起步  作为计算器用

+ - * /
>
    iex(10)> 200/15
    13.333333333333334

函数调用：
>
    iex(11)> div(200,15)
    13
    iex(12)> rem(200,15)
    5
    iex(13)> rem 200, 15
    5

后两个调用的语法 你可以选择一个你喜欢的 ，括号是可选的哦！

整数 可以用在需要float类型的地方 但反着不行！

- 四舍五入：
>iex(14)> round 200/15
 13

- 使用v({resultCount}) 引用值  v函数 可以引用出现在iex shell 中的值 比如v(-1) 表示最近一次的值

更多的数学计算
可以使用erlang的数学模块：
>
    iex(18)> :math.pi
    3.141592653589793
    iex(19)> :math.sin(0)
    0.0
    iex(20)> :math.sin(90)
    0.8939966636005579
    iex(21)> :math.cos(:math.pi)
    -1.0
    iex(22)> :math.cos(2 * :math.pi)
    1.0

    iex(23)> :math.pow(2,16)
    65536.0
    iex(24)> trunc :math.pow(2,16)
    65536
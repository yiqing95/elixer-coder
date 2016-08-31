重用的功能块

使用 fn 来创建函数

>
    iex(42)> fall_velocity = fn(distance) -> :math.sqrt(2 * 9.8* distance) end
    #Function<6.54118792/1 in :erl_eval.expr/5>

绑定变量到一个函数  其接受一个distance的参数（参数外的括号是可选的！） 函数返回 xxxx 啥东东 早忘了  物理题

函数调用
>
    iex(43)> fall_velocity.(20)
    19.79898987322333

匿名函数

elixir 提供了&简洁形式来定义匿名函数 & 捕获操作符 &1,&2 来引用参数
>
    iex(44)> fall_velocity = &(:math.sqrt(2 * 9.8 * &1))
    #Function<6.54118792/1 in :erl_eval.expr/5>
    iex(45)> fall_velocity 200
    ** (CompileError) iex:45: undefined function fall_velocity/1

    iex(45)> fall_velocity.(200)
    62.609903369994115

初学的话 还是使用命名参数版的函数定义吧
